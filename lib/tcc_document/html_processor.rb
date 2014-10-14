module TccDocument
  class HTMLProcessor

    def execute(content)
      content = decode_entities(content)
      content = simplify_tables(content)

      html = Nokogiri::HTML(content)

      html = fix_tables!(html)
      html = simulate_rowspan!(html)

      convert_to_xml(html)
    end

    private

    # Texto com HTML Entities convertido para os respectivos símbolos UTF8
    #
    # @param [String] content
    # @return [String] texto sem HTML Entities
    def decode_entities(content)
      # HTMLEntities converte &nbsp em \u00a0 (non-breaking space)
      # Isso causa problemas indesejados no Latex, portanto, vamos converter ambos
      # para espaços normais
      content = content.gsub('&nbsp;', ' ').gsub(/\u00a0/, ' ')

      # Converte caracteres HTML entities para equivalente em utf8
      reader = HTMLEntities.new
      reader.decode(content)
    end

    # Remove tags tbody e thead de tabelas para impressão correta no latex
    #
    # @param [String] content
    # @return [String] texto sem as tags mencionadas
    def simplify_tables(content)
      # Remove tags tbody e thead de tabelas para impressão correta no latex
      cleanup_pattern = %w(<tbody> </tbody> <thead> </thead>)
      cleanup_pattern.each { |pattern| content = content.gsub(pattern, '') }

      content
    end

    # Remove diversas tags que não são válidas dentro de tabelas para o Latex
    # E retorna o conteúdo em XHTML
    #
    # @param [Nokogiri::HTML::Document] nokogiri_html Documento HTML (Nokogiri)
    # @return [Nokogiri::HTML::Document] Documento HTML (Nokogiri) com a remoção dos itens inválidos nas tabelas
    def fix_tables!(nokogiri_html)
      # Remove tabela dentro de tabelas
      nokogiri_html.search('table').each do |table|
        table.search('table').remove
      end

      # Remove tags h1, h2, h3, h4, h5 das tabelas
      nokogiri_html.search('table').each do |table|
        table.replace table.to_s.gsub(/<h[0-9]\b[^>]*>/, '').gsub('</h>', '')
      end

      # Remove parágrafos dentro das tabelas, se tiver parágrafo não renderiza corretamente
      nokogiri_html.search('table').each do |table|
        table.replace table.to_s.gsub(/<p\b[^>]*>/, '').gsub('</p>', '')
      end

      # Remove espaço extra no inicio e final da celula da tabela
      nokogiri_html.search('td').each do |cell|
        cell.inner_html = cell.inner_html.strip
      end

      # Remove bullets dentro das tabelas
      nokogiri_html.search('table').each do |table|
        table.replace table.to_s.gsub('<ul>', '').gsub('</ul>', '').gsub('<li>', '').gsub('</li>', '')
      end

      nokogiri_html
    end

    # Simula rowspan realizando transformação no HTML para gerar equivalente as diretivas @rowspan
    #
    # @param [Nokogiri::HTML::Document] nokogiri_html Documento HTML (Nokogiri)
    # @return [Nokogiri::HTML::Document] Documento HTML (Nokogiri) com as alterações para simular @rowspan
    def simulate_rowspan!(nokogiri_html)

      td_position = Array.new
      tr_position = 0
      rowspan = 0

      nokogiri_html.search('tr').each_with_index do |tr, current_tr_position|
        tr.search('td').each_with_index do |td, current_td_position|

          # Verifica se a linha e a célula devem receber espaço em branco
          if tr_position > (current_tr_position - rowspan) and td_position.include? current_td_position
            td.replace "<td></td>#{td.to_s}"
          end

          if td.to_s.include? 'rowspan'
            rowspan = td.xpath('@rowspan').first.value.to_i
            td.replace td.to_s.gsub('rowspan', '')

            # Salva posição da linha que tenha rowspan
            tr_position = current_tr_position
            # Salva posição da célular que tenha rowspan
            td_position.push(current_td_position)
          end
        end
      end

      nokogiri_html
    end

    # Converte um documento manipulado pelo Nokogiri como HTML para XHTML e depois para XML
    # @return [Nokogiri::XML::Document]
    # @param [Nokogiri::HTML::Document] nokogiri_html
    def convert_to_xml(nokogiri_html)
      Nokogiri::XML(nokogiri_html.to_xhtml)
    end
  end
end