# Workaround for https://github.com/crystal-lang/crystal/issues/13873

class Compress::Zlib::Reader < IO
  @in_buffer = Pointer(UInt8).null
  @out_buffer = Pointer(UInt8).null
  @in_buffer_rem = Bytes.empty
  @out_count = 0
  @sync = false
  @read_buffering = true
  @flush_on_newline = false
  @buffer_size = IO::DEFAULT_BUFFER_SIZE
end

class Compress::Deflate::Reader < IO
  @in_buffer = Pointer(UInt8).null
  @out_buffer = Pointer(UInt8).null
  @in_buffer_rem = Bytes.empty
  @out_count = 0
  @sync = false
  @read_buffering = true
  @flush_on_newline = false
  @buffer_size = IO::DEFAULT_BUFFER_SIZE
end

require "compress/zlib"
require "compress/deflate"
