# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include Geoblacklight::SolrDocument
  include WmsRewriteConcern

  # self.unique_key = 'id'
  self.unique_key = 'layer_slug_s'

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

  # @TODO: EWL
  # Can't imagine why we'd want more than one
  #
  # SolrDocumentSidecar is the ActiveRecord sibling to SolrDocument
  def sidecar
    SolrDocumentSidecar.find_or_create_by!(document_id: id, document_type: self.class.to_s)
  end
end