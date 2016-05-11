# Generated via
#  `rails generate curation_concerns:work Sample`
class Sample < ActiveFedora::Base
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  validates :title, presence: { message: 'Your work must have a title.' }

  has_and_belongs_to_many :complexTitle, predicate: ::RDF::Vocab::DC11.title, class_name: "ComplexTitle"
  has_and_belongs_to_many :prefLabel, predicate: ::RDF::Vocab::SKOSXL.prefLabel, class_name: "ComplexTitle"
  has_and_belongs_to_many :alternativeTitle, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/mods/alternativeTitle'), class_name: "ComplexTitle"
  has_and_belongs_to_many :translatedTitle, predicate: ::RDF::URI.new('http://opaquenamespace.org/ns/mods/translatedTitle'), class_name: "ComplexTitle"

  property :simple_alternative, predicate: ::RDF::Vocab::DC.alternative, multiple: true do |index|
    index.as :stored_searchable
  end

  property :abstract, predicate: ::RDF::Vocab::DC.abstract, multiple: true do |index|
    index.as :stored_searchable, :symbol
  end



  property :hasType, predicate: ::RDF::Vocab::EDM.hasType, multiple: true do |index|
    index.as :stored_searchable
  end

  def self.indexer
    SampleIndexer
  end


  def paranoid_edit_permissions
    [
        { key: :edit_users, message: 'Depositor must have edit access', condition: ->(obj) { !true } },
        { key: :edit_groups, message: 'Public cannot have edit access', condition: ->(obj) { false } },
        { key: :edit_groups, message: 'Registered cannot have edit access', condition: ->(obj) { false } }
    ]
  end
end
