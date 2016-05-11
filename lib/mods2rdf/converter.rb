module Mods2rdf
  class Converter

    def self.process(xml, title_type, user_key)
      @xml = Nokogiri::XML(xml).remove_namespaces!
      @object = Sample.new

      #Three required Curation Concerns fields
      @object.visibility = "open"
      @object.depositor = user_key
      current_time = Time.now
      @object.date_uploaded =   current_time.strftime("%Y-%m-%d")
      @object.date_modified =   current_time.strftime("%Y-%m-%d")

      case title_type
        when 'Simple'
          process_simple_title
        when 'Complex'
          process_complex_title
      end

      process_genre
      process_abstract

      @object.save!
      return @object.id
    end

    #FIXME: language...
    #FIXME: "<<" and ".append" don't seem to work so setting these weird...
    def self.process_simple_title
      @xml.xpath('//mods/titleInfo').each do |title_info|
        usage = title_info.attributes['usage'].value if title_info.attributes['usage'].present?
        language = title_info.attributes['lang'].value if title_info.attributes['lang'].present?
        nonSort = title_info.xpath('./nonSort').present? ? title_info.xpath('./nonSort').first.text : ''
        subtitle = title_info.xpath('./subtitle').first.text if title_info.xpath('./subtitle').present?

        full_title = nonSort + title_info.xpath('./title').first.text
        full_title = full_title + ' : ' + subtitle if subtitle.present?

        title_info.xpath('./partNumber').each do |part_num|
          full_title = full_title + '. ' + part_num.text
        end

        title_info.xpath('./partName').each do |part_name|
          full_title = full_title + '. ' + part_name.text
        end


        if usage == 'primary'
          @object.title = @object.title + [full_title]
          type = title_info.attributes['type'].value if title_info.attributes['type'].present?
          value_uri = title_info.attributes['valueURI'].value if title_info.attributes['valueURI'].present?
          if type == 'uniform' && value_uri.present?
            @object.title = [RDF::URI.new(value_uri)]
          end
        else
          @object.simple_alternative << full_title
        end
      end
    end

    #FIXME: language...
    #FIXME: "<<" and ".append" don't seem to work so setting these weird...
    #FIXME: Fedora seems to break on titles that are not literals?!?
    def self.process_complex_title
      @xml.xpath('//mods/titleInfo').each do |title_info|
        usage = title_info.attributes['usage'].value if title_info.attributes['usage'].present?
        type = title_info.attributes['type'].value if title_info.attributes['type'].present?
        supplied = title_info.attributes['supplied'].value if title_info.attributes['supplied'].present?

        value_uri = title_info.attributes['valueURI'].value if title_info.attributes['valueURI'].present?
        language = title_info.attributes['lang'].value  if title_info.attributes['lang'].present?
        nonSort = title_info.xpath('./nonSort').present? ? title_info.xpath('./nonSort').first.text : ''
        subtitle = title_info.xpath('./subtitle').first.text if title_info.xpath('./subtitle').present?

        full_title = title_info.xpath('./title').first.text
        full_title = full_title + ' : ' + subtitle if subtitle.present?

        title_info.xpath('./partNumber').each do |part_num|
          full_title = full_title + '. ' + part_num.text
        end

        title_info.xpath('./partName').each do |part_name|
          full_title = full_title + '. ' + part_name.text
        end

        title_for_sort = full_title
        full_title = nonSort + full_title


        if usage == 'primary' && type == 'uniform' && value_uri.present?
          @object.title = [full_title]
          @object.complexTitle =  [RDF::URI.new(value_uri)]
        else
          @title = ComplexTitle.new
          @title.prefLabel = full_title
          @title.titleForSort = title_for_sort
          @title.supplied = supplied if supplied.present?
          @title.save!

          if usage == 'primary'
            @object.title = @object.title + [full_title]
            @object.complexTitle = @object.complexTitle + [@title]
            if @object.complexTitle.size == 1
              @object.prefLabel = [@title]
            end
          elsif type == 'alternative' || type.blank?
            @object.alternativeTitle = @object.alternativeTitle + [@title]
          elsif type == 'translated'
            @object.translatedTitle = @object.translatedTitle + [@title]
          end
        end

      end

    end

    def self.process_genre
      @xml.xpath('//mods/genre').each do |genre_info|
        value_uri = genre_info.attributes['valueURI'].value if genre_info.attributes['valueURI'].present?
        authority_uri = genre_info.attributes['authorityURI'].value if genre_info.attributes['authorityURI'].present?
        text_value = genre_info.text if genre_info.present?

        if authority_uri.present? and value_uri.present? && value_uri.match('/').blank?
          value_uri = authority_uri + value_uri
        end

        if value_uri.present?
          @object.hasType = @object.hasType + [::RDF::URI.new(value_uri)]
        elsif text_value.present?
          @object.hasType = @object.hasType + [text_value]
        end
      end
    end

    def self.process_abstract
      @xml.xpath('//mods/abstract').each do |abstract_info|
        text_value = abstract_info.text if abstract_info.present?



        if text_value.present?
          @object.abstract = @object.abstract + [abstract]
        end
      end
    end
  end
end
