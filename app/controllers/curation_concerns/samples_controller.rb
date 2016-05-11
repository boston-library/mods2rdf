# Generated via
#  `rails generate curation_concerns:work Sample`

class CurationConcerns::SamplesController < ApplicationController
  include CurationConcerns::CurationConcernController
  self.curation_concern_type = Sample

  # Gives the class of the show presenter. Override this if you want
  # to use a different presenter.
  def show_presenter
    # CurationConcerns::WorkShowPresenter
    ::SamplePresenter
  end
end
