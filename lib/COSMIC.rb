module Structure
  def self.COSMIC_residues
    @COSMIC_residues ||= Persist.persist("COSMIC_residues", :tsv, :dir => Rbbt.var.persistence.find(:lib)) do
                           isoform_residue_mutations = TSV.setup({}, :key_field => "Isoform:residue", :fields => ["Genomic Mutations"], :type => :flat)

                           db = COSMIC.knowledge_base.get_database('mutation_isoforms')
                           db.monitor = {:desc => "Processing COSMIC", :step => 10000}
                           db.through  do |mutation, mis|
                             protein_residues = {}
                             mis.each do |mi|
                               next unless mi =~ /(ENSP\d+):([A-Z])(\d+)([A-Z])$/ and $2 != $4
                               residue = $3.to_i
                               protein = $1
                               isoform_residue_mutations[[protein, residue] * ":"] ||= []
                               isoform_residue_mutations[[protein, residue] * ":"] << mutation
                             end
                           end
                           isoform_residue_mutations
                         end
  end

  def self.COSMIC_mutation_annotations
    @COSMIC_mutation_annotations ||= begin
                                       fields = [
                                         'Mutation AA',
                                         'Primary site',
                                         'Site subtype',
                                         'Primary histology',
                                         'Histology subtype',
                                         'Genome-wide screen',
                                         'Mutation somatic status',
                                         'Sample source',
                                         'Tumour origin'
                                         ]
                                       COSMIC.mutations.tsv :key_field => "Genomic Mutation", :fields => fields, :persist => true, :unamed => true, :type => :double
                                     end
  end
end


