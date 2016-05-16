class Subject < ActiveFedora::Base

  has_and_belongs_to_many :spatial, predicate: ::RDF::Vocab::DC.spatial, class_name: "Spatial"

  property :prefLabel, predicate: ::RDF::SKOS.prefLabel, multiple: false do |index|
    index.as :stored_searchable
  end

  property :label, predicate: ::RDF::Vocab::RDFS.label, multiple: false do |index|
    index.as :stored_searchable
  end

  property :exactMatch, predicate: ::RDF::Vocab::SKOS.exactMatch, multiple: true do |index|
    index.as :stored_searchable, :symbol
  end

  property :closeMatch, predicate: ::RDF::Vocab::SKOS.closeMatch, multiple: true do |index|
    index.as :stored_searchable, :symbol
  end



  def assign_id
    noid_service.mint
  end


  private
  def noid_service
    @noid_service ||= ActiveFedora::Noid::Service.new
  end
end