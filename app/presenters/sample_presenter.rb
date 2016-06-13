class SamplePresenter < CurationConcerns::WorkShowPresenter
  delegate :hasType, to: :solr_document
  delegate :alternativeTitle, to: :solr_document
  delegate :translatedTitle, to: :solr_document
  delegate :abstract, to: :solr_document
  delegate :dcsubject, to: :solr_document
  delegate :notes, to: :solr_document
  delegate :toc, to: :solr_document
end