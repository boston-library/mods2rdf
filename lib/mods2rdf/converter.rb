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
      process_subject

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

    def self.process_subject
      @xml.xpath('//mods/subject').each do |subject_info|
        value_uri = subject_info.attributes['valueURI'].value if subject_info.attributes['valueURI'].present?
        authority_uri = subject_info.attributes['authorityURI'].value if subject_info.attributes['authorityURI'].present?
        authority = subject_info.attributes['authority'].value if subject_info.attributes['authority'].present?
        if authority_uri.present? and value_uri.present? && value_uri.match('/').blank?
          value_uri = authority_uri + value_uri
        end


        full_subject_list = []
        geographic_component = nil
        subject_info.children.each do |child|
          if ['topic', 'genre'].include? child.name
            full_subject_list << child.text
          end

          if child.name == 'geographic'
            full_subject_list << child.text
            geographic_component = child.text
          end
        end

        full_subject_value = full_subject_list.join('--')



        #Find matches for the term
        subject_match = Subject.where(:prefLabel=>full_subject_value)

        if subject_match.first.present?
          @object.dcsubject = @object.dcsubject + [subject_match.first]
          if !(subject_match.first.exactMatch.include? value_uri)
            subject_match.first.exactMatch = subject_match.first.exactMatch + [value_uri]
            subject_match.first.exactMatch.save!
          end


        elsif full_subject_value.present?
          new_subject = Subject.new
          new_subject.prefLabel = full_subject_value
          new_subject.exactMatch = [value_uri]
          @object.dcsubject = @object.dcsubject + [new_subject]
          if geographic_component.present?
            spatial_match = Spatial.where(:prefLabel=>geographic_component)
            if spatial_match.first.present?

              geomash_hash = Geomash.parse(geographic_component)
              if geomash_hash.present? and geomash_hash[:tgn].present?
                if geomash_hash[:term_differs_from_tgn]
                  spatial_match.first.closeMatch = spatial_match.first.closeMatch + ["http://vocab.getty.edu/tgn/#{geomash_hash[:tgn][:id]}"]
                else
                  spatial_match.first.exactMatch = spatial_match.first.exactMatch + ["http://vocab.getty.edu/tgn/#{geomash_hash[:tgn][:id]}"]
                end
              end
              
              new_subject.spatial = [spatial_match.first]
            else
              new_spatial = Spatial.new
              new_spatial.prefLabel = geographic_component
              new_spatial.label = geographic_component
              geomash_hash = Geomash.parse(geographic_component)
              if geomash_hash.present? and geomash_hash[:tgn].present?
                if geomash_hash[:term_differs_from_tgn]
                  new_spatial.closeMatch = new_spatial.closeMatch + ["http://vocab.getty.edu/tgn/#{geomash_hash[:tgn][:id]}"]
                else
                  new_spatial.exactMatch = new_spatial.exactMatch + ["http://vocab.getty.edu/tgn/#{geomash_hash[:tgn][:id]}"]
                end
              end
              new_spatial.save!
              new_subject.spatial = [new_spatial]
            end
          end
          new_subject.save!


        end

      end
    end
  end
end
