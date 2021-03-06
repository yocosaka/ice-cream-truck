class Api::V1::SalesController < ApplicationController
  before_action :set_sale, only: %i[show]

  def index
    sales = Sale.all
    render json: sales, status: 200
  end

  def show
    render json: @sale, status: 200
  end

  def create
    # check if the stock is ok
    product = Product.find(sale_params[:product_id])
    if product.stock.positive?
      @sale = Sale.new(sale_params)
      if @sale.save
        current_stock = product.stock # Reduce stock from the product
        product.update_attribute(:stock, current_stock - 1)
        render json: { message: 'ENJOY!', sale: @sale, product: product }, status: 201
      else
        render json: { message: 'Something is wrong' }, status: 400
      end
    else
      render json: { message: 'SO SORRY! We have no stock.' }, status: 404
    end
  end

  private

  def sale_params
    params.require(:sale).permit(:sold_date, :product_id)
  end

  def set_sale
    @sale = Sale.find(params[:id])
  end
end
