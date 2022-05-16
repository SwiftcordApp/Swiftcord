//
//  DecompressionEngine.swift
//  DiscordAPI
//
//  Created by Vincent Kwok on 13/5/22.
//

import Foundation
import Compression
import OSLog

public class DecompressionEngine {
    private static let ZLIB_SUFFIX = Data([0x00, 0x00, 0xff, 0xff]), BUFFER_SIZE = 32_768
    
	private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? DiscordAPI.subsystem, category: "DecompressionEngine")
    private var buf = Data(), stream: compression_stream, status: compression_status,
                decompressing = false
    
    public init() {
        stream = UnsafeMutablePointer<compression_stream>.allocate(capacity: 1).pointee
        status = compression_stream_init(&stream, COMPRESSION_STREAM_DECODE, COMPRESSION_ZLIB)
        
        guard status != COMPRESSION_STATUS_ERROR else {
            DecompressionEngine.log.critical("Couldn't init compression stream!")
            return
        }
    }
    
    deinit {
        compression_stream_destroy(&stream)
    }
    
    public func push_data(_ data: Data) -> String? {
        buf.append(data)
        
        guard buf.count >= 4, buf.suffix(4) == DecompressionEngine.ZLIB_SUFFIX else {
            DecompressionEngine.log.debug("Appending to buf, current buf len: \(self.buf.count, privacy: .public)")
            return nil
        }
        
        // Figure out how to make a shared zlib decompression context
        let output = decompress(buf)
        
        buf.removeAll()
        return String(decoding: output, as: UTF8.self)
    }
}

public extension DecompressionEngine {
    fileprivate func decompress(_ data: Data) -> Data {
        let initialSize = data.count
        guard !decompressing else {
            DecompressionEngine.log.warning("Another decompression is currently taking place, skipping")
            return Data()
        }
        decompressing = true
        
        // ZLib header, strip it if necessary
        var data = data.prefix(2) == Data([0x78, 0x9C]) ? data.dropFirst(2) : data
        
        // Configure stream source and destinations (will be changed in loop)
        stream.src_size = 0
        let bufferSize = DecompressionEngine.BUFFER_SIZE
        let destinationBufferPointer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        stream.dst_ptr = destinationBufferPointer
        stream.dst_size = bufferSize
        
        // Buffer for decompressed chunks
        var decompressed = Data(), srcChunk: Data?
        
        defer {
            DecompressionEngine.log.debug("Decompressed \(initialSize)B -> \(decompressed.count, privacy: .public)B")
            decompressing = false
            destinationBufferPointer.deallocate()
        }
        
        // Loop over this until there's nothing left to decompress or an error occurred
        repeat {
            var flags = Int32(0)
            
            // If this iteration has consumed all of the source data,
            // read a new tempData buffer from the input file.
            if stream.src_size == 0 {
                srcChunk = data.prefix(bufferSize)
                data = data.dropFirst(srcChunk!.count)
                
                stream.src_size = srcChunk!.count
                if stream.src_size < bufferSize {
                    // This technically shouldn't be used this way...
                    flags = Int32(COMPRESSION_STREAM_FINALIZE.rawValue)
                }
            }
            
            // Perform compression or decompression.
            if let srcChunk = srcChunk {
                let count = srcChunk.count
                
                srcChunk.withUnsafeBytes {
                    let baseAddress = $0.bindMemory(to: UInt8.self).baseAddress!
                    
                    stream.src_ptr = baseAddress.advanced(by: count - stream.src_size)
                    status = compression_stream_process(&stream, flags)
                }
            }

            switch status {
            case COMPRESSION_STATUS_OK, COMPRESSION_STATUS_END:
                // Get the number of bytes put in the destination buffer. This is the difference between
                // stream.dst_size before the call (here bufferSize), and stream.dst_size after the call.
                let count = bufferSize - stream.dst_size
                
                let outputData = Data(bytesNoCopy: destinationBufferPointer,
                                      count: count,
                                      deallocator: .none)
                decompressed.append(contentsOf: outputData)
                
                // Reset the stream to receive the next batch of output.
                stream.dst_ptr = destinationBufferPointer
                stream.dst_size = bufferSize
            case COMPRESSION_STATUS_ERROR: return decompressed
                // This "error" happens when decompression is done, what a hack
            default: break
            }
        } while status == COMPRESSION_STATUS_OK
        return decompressed
    }
}
