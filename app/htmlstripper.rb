require 'kconv'
require 'rubygems'
require 'nokogiri'

class HTMLStripper

  def HTMLStripper.strip(src, url = nil)

    src = src.toutf8.chars.map{ |s|

      s.valid_encoding? ? s : "\uFFFD"

    }.join("")

    dom = begin

      Nokogiri::HTML.parse(src, url, "UTF-8")

    rescue

      retry

    end

    dom.xpath('//style|//script').each{ |n|

      n.unlink

    }

    return dom.xpath('//text()').map{ |n|

      n.content

    }.join(' ').gsub(/\p{WSpace}+/,' ').strip

  end

end
