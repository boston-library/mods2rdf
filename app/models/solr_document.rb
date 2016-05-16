# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  # Adds CurationConcerns behaviors to the SolrDocument.
  include CurationConcerns::SolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models. 

  use_extension( Hydra::ContentNegotiation )

  def hasType
    fetch('hasType_tesim', [])
  end

  def abstract
    fetch('abstract_ssim', [])
  end

  def dcsubject
    fetch('dcsubject_text_ssim', [])
  end

  def translatedTitle
    final_return = []
    supplied_array = fetch('trans_supplied_ssm', [])
    prefLabel_array = fetch('trans_prefLabel_ssm', [])
    prefLabel_array.each_with_index do |pref, index|
      pref = pref + ' (supplied)' unless supplied_array[index] == 'no' or supplied_array[index] == 'false'
      final_return << pref
    end
    final_return
  end

  def alternativeTitle
    final_return = []
    supplied_array = fetch('alt_supplied_ssm', [])
    prefLabel_array = fetch('alt_prefLabel_ssm', [])
    prefLabel_array.each_with_index do |pref, index|
      pref = pref + ' (supplied)' unless supplied_array[index] == 'no' or supplied_array[index] == 'false'
      final_return << pref
    end
    final_return
  end

end
