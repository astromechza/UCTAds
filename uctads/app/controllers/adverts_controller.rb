class AdvertsController < ApplicationController

  def index
    @adverts = Advert.all
  end

  def new
    @advert = Advert.new
    @categories = Category.hash_tree
  end

  def new_ad_form
    category = Category.find(advert_category_param[:category_id])
    @advert = Advert.new
    @advert.category = category
    @fieldsdef = category.self_and_ancestors.map {|p| p.fields}.inject {|a,b| a.merge!(b)}
  end

  def create
    @advert = Advert.new(advert_form_params)
    if @advert.save
        redirect_to @advert, notice: "Advert successfully created."
    else
        @fieldsdef = @advert.category.self_and_ancestors.map {|p| p.fields}.inject {|a,b| a.merge!(b)}
        render action: 'new_ad_form'
    end
  end

  def show
    @advert = Advert.find(params[:id])
  end

  private

    def advert_category_param
      params.require(:advert).permit(:category_id)
    end

    def advert_form_params
      r = params.require(:advert).permit(:title, :description, :fieldvalues, :category_id)
      r['fieldvalues'] = JSON.parse(r['fieldvalues'])
      return r
    end

end
