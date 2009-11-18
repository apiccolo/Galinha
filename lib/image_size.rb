# image_size.rb
#
# Copyright (c) 2007 Rob Biedenharn
#   Rob [at] AgileConsultingLLC.com
#   Rob_Biedenharn [at] alum.mit.edu
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'stringio'              # strictly for the ::of_blob

# Given a duck-typed +IO+ object (which could be from +StringIO+, +File+,
# +open-uri+, etc.) containing image data, attempt to grab the width and
# height.  As a convenience, the size is defined as "#{width}x#{height}"
#
# The description of JPEG and GIF files was taken from the
# /usr/share/file/magic file from Mac OS X.  The PNG description was
# validated against the spec at
# http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html
class ImageSize

  # Prepare a new IO source.  Should support IO#pos=, IO#read, and IO#gets.
  #
  # Supported formats:
  # * JPEG
  # * PNG
  # * GIF
  def initialize source
    @image = source
    @header = nil
    @width = @height = nil
  end

  # A convenience method to pull size information from a file
  def self.of_file path
    obj = nil
    File.open(path) do |f|
      obj = new(f)
      obj.size
    end
    obj
  end

  # A convenience method to pull size information from a blob (i.e., a +String+)
  def self.of_blob blob
    obj = nil
    sio = ::StringIO.new(blob)
    obj = self.new(sio)
    obj.size
    obj
  end

  def size
    [self.width,self.height] * 'x'
  end

  [ :width, :height ].each do |property|
    meth = "def #{property}; @#{property} ||= case\n"
    [ :jpeg, :png, :gif ].each do |format|
      meth << " when #{format}? : #{format}_#{property}; "
    end
    meth << " else -1; end; end"
    class_eval meth
  end

  protected
  # Generic header takes bytes from the front.  Once a type is known, a
  # format-specific header is retrieved from the data.
  def header
    @header unless @header.nil?
    @image.pos=0
    @image.read(100)
  end

  # ==================================================
  # # GIF
  # 0  string    GIF8    GIF image data
  # >4  string    7a    \b, version 8%s,
  # >4  string    9a    \b, version 8%s,
  def gif?
    header[0...6] =~ /GIF8[79]a/
  end
  # >6  leshort    >0    %hd x
  # >8  leshort    >0    %hd
  def gif_width
    gif_header[6...8].unpack('v').first
  end
  def gif_height
    gif_header[8...10].unpack('v').first
  end

  def gif_header
    @header ||= read_gif_header
  end

  def read_gif_header
    @image.pos=0
    @image.read(10)
  end

  # ==================================================
  # PNG
  # # 137 P N G \r \n ^Z \n [4-byte length] H E A D [HEAD data] [HEAD crc] ...
  # #
  # 0  string    \x89PNG    PNG image data,
  # >4  belong    !0x0d0a1a0a  CORRUPTED,
  # >4  belong    0x0d0a1a0a
  def png?
    header[0...8] == "\x89PNG\r\n\x1a\n"
  end
  # >>16  belong    x    %ld x
  # >>20  belong    x    %ld,
  #
  # and from the spec: http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html
  #
  # 4.1.1. IHDR Image header
  #
  # The IHDR chunk must appear FIRST. It contains:
  #
  #    Width:              4 bytes
  #    Height:             4 bytes
  #    Bit depth:          1 byte
  #    Color type:         1 byte
  #    Compression method: 1 byte
  #    Filter method:      1 byte
  #    Interlace method:   1 byte
  def png_width
    png_header[16...20].unpack('N').first
  end
  def png_height
    png_header[20...24].unpack('N').first
  end

  def png_header
    @header ||= read_png_header
  end

  def read_png_header
    @image.pos=0
    @image.read(37)             # through the end of the IHDR chunk
  end

  # ==================================================
  # JPEG
  def jpeg?
    # 0  beshort    0xffd8    JPEG image data
    header[0...2] == "\xff\xd8" # ffd8 is the SOI - Start of Image marker
  end

  def jpeg_header
    @header ||= read_jpeg_header
  end

  # The JFIF header is nasty in the sense that the size marker isn't in a
  # fixed place.  Build the header up in pieces by reading the markers and
  # data sizes until an "interesting" segment is found.
  JPEG_SEG = /\xff[\xc0\xc1\xc2]/nm
  def read_jpeg_header
    @image.pos=0
    buffer = ''

    buffer << @image.read(4)    # ffd8 ff__
    found_segment = false       # the first one has to be ffe_ which is an
                                # APPx segment and not one that would match
                                # our interesting JPEG_SEG pattern
    while buffer[-2,2] != "\xff\xd9" # ffd9 is the EOI - End of Image marker
      buffer << @image.read(2)
      datasize = buffer[-2,2].unpack('n').first
      # datasize includes the 2 bytes for itself so this gets the data
      # (datasize-2 bytes) and the next marker (2 bytes), too
      buffer << @image.read(datasize)
      break if found_segment
      found_segment = buffer[-2,2] =~ JPEG_SEG
    end
    buffer
  end

  # Or, we can show the encoding type (I've included only the three most common)
  # and image dimensions if we are lucky and the SOFn (image segment) is here:
  # >(4.S+5)  byte    0xC0    \b, baseline
  # >>(4.S+6)  byte    x    \b, precision %d
  # >>(4.S+7)  beshort    x    \b, %dx
  # >>(4.S+9)  beshort    x    \b%d
  # >(4.S+5)  byte    0xC1    \b, extended sequential
  # >>(4.S+6)  byte    x    \b, precision %d
  # >>(4.S+7)  beshort    x    \b, %dx
  # >>(4.S+9)  beshort    x    \b%d
  # >(4.S+5)  byte    0xC2    \b, progressive
  # >>(4.S+6)  byte    x    \b, precision %d
  # >>(4.S+7)  beshort    x    \b, %dx
  # >>(4.S+9)  beshort    x    \b%d

  DIM_RE = Regexp.new(%{#{JPEG_SEG}...(..)(..)}, Regexp::MULTILINE, 'n')

  def jpeg_width
    begin
      jpeg_header[DIM_RE, 2].unpack('n').first if jpeg?
    rescue => e
      raise ArgumentError, "Looking for #{DIM_RE} in JPEG data:\n#{jpeg_header.unpack('H*').first.scan(/.{2,64}/).join("\n")}\n"
    end
  end
  def jpeg_height
    begin
      jpeg_header[DIM_RE, 1].unpack('n').first if jpeg?
    rescue => e
      raise ArgumentError, "Looking for #{DIM_RE} in JPEG data:\n#{jpeg_header.unpack('H*').first.scan(/.{2,64}/).join("\n")}\n"
    end
  end

end