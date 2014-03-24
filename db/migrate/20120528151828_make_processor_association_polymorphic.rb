class MakeProcessorAssociationPolymorphic < ActiveRecord::Migration
  def change
    add_column :payments, :processor_type, :string
  end
end
