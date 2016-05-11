class ComplexTitle < ActiveFedora::Base
  property :prefLabel, predicate: ::RDF::SKOS.prefLabel, multiple: false do |index|
    index.as :stored_searchable
  end

  property :titleForSort, predicate: 'http://opaquenamespace.org/ns/mods/titleForSort', multiple: false do |index|
    index.as :stored_searchable
  end

  property :supplied, predicate: 'http://opaquenamespace.org/ns/mods/supplied', multiple: false do |index|
    index.as :stored_searchable
  end



  def assign_id
    noid_service.mint
  end


  private
  def noid_service
    @noid_service ||= ActiveFedora::Noid::Service.new
  end
end