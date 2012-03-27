class StoreController < ApplicationController
  before_filter :find_cart, :except => :empty_cart
  def index
    @products = Product.find_products_for_sale
    @cart = find_cart
  end

  def add_to_cart
    product = Product.find(params[:id])
    @cart = find_cart          # method to find the Cart object from session or initialze a new one
    @current_item = @cart.add_product(product)
   # redirect_to_index         # By Adding this we redirect to index page where we see Product Cart in side bar
    respond_to do |format|   # for javascript call 
      format.js 
      
    end
  rescue ActiveRecord::RecordNotFound
    logger.error("Attempt to access invalid product #{params[:id]}")
    redirect_to_index("Invalid product" )
    end

  def empty_cart
    session[:cart] = nil
    redirect_to_index("Your cart is currently empty" )
  end
  
  def checkout
    @cart = find_cart
    if @cart.items.empty?
      redirect_to_index("Your Cart is Empty")
    else
      @order = Order.new
    end
  end
  
  def save_order
    @cart = find_cart
    @order = Order.new(params[:order]) # order parameter i have passed it from checkout.html.erb page
    @order.add_line_items_from_cart(@cart)
    if @order.save
      session[:cart] = nil
      redirect_to_index("Thank you for your order")
    else
      render :action => 'checkout'
    end
  end

  private

  def redirect_to_index(msg = nil)
    flash[:notice] = msg if msg
    redirect_to :action => 'index'

  end

  def find_cart
    @cart = (session[:cart] ||= Cart.new)
  end

end
