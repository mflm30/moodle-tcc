module ControllersUtils

  def self.remove_blank_lines(content)
    ## O CKEditor está realizando a limpeza de linhas em branco
    # config.autoParagraph = false; # no config.sj do editor

    return nil if content.nil?
    newContent = content
    ## tira linhas em branco
    # U+00A0	/	194 160	/ NO-BREAK SPACE
    space2 = 194.chr("UTF-8")+160.chr("UTF-8")
    newContent.gsub!(/#{space2}/) {" "}
    space1 = 160.chr("UTF-8")
    newContent.gsub!(/#{space1}/) {" "}

    # lines = newContent.split("\r\n")
    # newLines = lines.map { | x |
    #   x unless x.empty?
    # }.compact.join("\r\n")

    lines = newContent.split("\r\n")
    newLines = lines.map { | x |
      if (/^(<p(\s[^<]*|)>(\s*(<br(\s*\/?|)>|))*(\s)*<\/p\s*>|)(\s*(<br(\s*\/?|)>|))*(\s)*$/.match(x).blank? )
        #
        # se não encontrar parágrafo e texto com espaços
        # então adiciona o texto em newLines
        x unless x.empty?
        # senão, se encontrar parágrafo e texto com espaços
        # então abandona o texto e não adiciona em newLines
      # else
        # "<p sdfsdfsdf   >  <br    /> </p   > <br   >  <br />"
        # "<p sdfsdfsdf   >  <br    /> </p   > <br   >  "
        # "<p></p>"
        # "<br>"
        # "<p></p><br>"
        # "<p><br></p><br>"
      end
    }.compact.join("\r\n")
    newLines.chomp!
    newContent = newLines

    nokogiri_html = Nokogiri::HTML.fragment(newContent)

    # Teste
    nokogiri_html.search('p').each do | paragraph |
      paragraph.replace  paragraph.to_s.gsub(/<p(\s+[^<>]*|)>/, '<p>')
    end

    nokogiri_html.search('font').each do | paragraph |
      paragraph.replace  paragraph.to_s.gsub(/<font(\s+[^<>]*|)>/, '').gsub('</font>', '')
    end

    nokogiri_html.search('li').each do | paragraph |
      paragraph.replace  paragraph.to_s.gsub(/<li(\s+[^<>]*|)>/, '<li>')
    end

    nokogiri_html.search('div').each do | paragraph |
      paragraph.replace  paragraph.to_s.gsub(/<div(\s+[^<>]*|)>/, '').gsub('</div>', '')
    end

    nokogiri_html.search('span').each do | paragraph |
      paragraph.replace  paragraph.to_s.gsub(/<span(\s+[^<>]*|)>/, '').gsub('</span>', '')
    end

    newContent = nokogiri_html.to_html
    newContent
  end

end