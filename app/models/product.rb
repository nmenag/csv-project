# == Schema Information
#
# Table name: products
#
#  id         :integer          not null, primary key
#  name       :string
#  price      :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Product < ActiveRecord::Base

  def self.to_csv
    tsv_str = CSV.generate(col_sep: "\t") do |tsv|
      tsv << column_names
      all.each do |product|
        tsv << product.attributes.values_at(*column_names)
      end
    end
  end

  def self.import(products)

    ActiveRecord::Base.transaction do

      products.each do |p|
        product = self.new
        product.name = p[:name]
        product.price = p[:price]

        unless product.save
          errors << "Error en #{product.name}: #{product.errors.full_messages.join(", ")}."
          raise ActiveRecord::Rollback, product.errors.full_messages
        end
      end
    end
  end
end
