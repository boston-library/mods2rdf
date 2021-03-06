class SampleIndexer < CurationConcerns::WorkIndexer
  def generate_solr_document
    super.tap do |solr_doc|

      if object.complexTitle.present?
        supplied_array = []
        titleForSort_array = []
        prefLabel_array = []
        object.complexTitle.each do |title_obj|
          supplied_array << title_obj.supplied.present? ? title_obj.supplied : 'no'
          titleForSort_array << title_obj.titleForSort
          prefLabel_array << title_obj.prefLabel
        end

        Solrizer.set_field(solr_doc,
                           'supplied',
                           supplied_array,
                           :displayable)

        Solrizer.set_field(solr_doc,
                           'titleForSort',
                           titleForSort_array,
                           :displayable)

        Solrizer.set_field(solr_doc,
                           'prefLabel',
                           prefLabel_array,
                           :displayable)

        solr_doc['this_should_work_ssim'] = titleForSort_array

        #No idea why this is set... seems to be a bug in Hydra Works
        solr_doc['title_tesim'] -= [title_obj.id.to_s]
        solr_doc['title_ssim'] -= [title_obj.id.to_s]
      end

      if object.alternativeTitle.present?
        supplied_array = []
        titleForSort_array = []
        prefLabel_array = []
        object.alternativeTitle.each do |title_obj|
          supplied_array << title_obj.supplied.present? ? title_obj.supplied : 'no'
          titleForSort_array << title_obj.titleForSort
          prefLabel_array << title_obj.prefLabel
        end

        Solrizer.set_field(solr_doc,
                           'alt_supplied',
                           supplied_array,
                           :displayable)

        Solrizer.set_field(solr_doc,
                           'alt_titleForSort',
                           titleForSort_array,
                           :displayable)

        Solrizer.set_field(solr_doc,
                           'alt_prefLabel',
                           prefLabel_array,
                           :displayable)
      end

      if object.translatedTitle.present?
        supplied_array = []
        titleForSort_array = []
        prefLabel_array = []
        object.translatedTitle.each do |title_obj|
          supplied_array << title_obj.supplied.present? ? title_obj.supplied : 'no'
          titleForSort_array << title_obj.titleForSort
          prefLabel_array << title_obj.prefLabel
        end

        Solrizer.set_field(solr_doc,
                           'trans_supplied',
                           supplied_array,
                           :displayable)

        Solrizer.set_field(solr_doc,
                           'trans_titleForSort',
                           titleForSort_array,
                           :displayable)

        Solrizer.set_field(solr_doc,
                           'trans_prefLabel',
                           prefLabel_array,
                           :displayable)
      end


      if object.dcsubject.present?
        solr_doc['dcsubject_text_ssim'] = []
        object.dcsubject.each do |subj|
          solr_doc['dcsubject_text_ssim'] << subj.prefLabel
        end

      end

      solr_doc['toc_text_ssim'] = object.toc

      solr_doc['notes_ssim'] = object.note_simple

      if object.note_complex.present?
        object.note_complex.each do |note|
          if note.noteType.present?
            solr_doc['notes_ssim'] << note.noteType.capitalize + ': ' + note.label
          else
            solr_doc['notes_ssim'] << note.label
          end

        end

      end





    end

  end
end