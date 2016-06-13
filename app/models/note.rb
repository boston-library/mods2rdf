class Note < ActiveFedora::Base
  property :label, predicate: ::RDF::Vocab::RDFS.label, multiple: false do |index|
    index.as :stored_searchable
  end

  property :noteType, predicate: 'http://bibframe.org/vocab/noteType', multiple: false do |index|
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