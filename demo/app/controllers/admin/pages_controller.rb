class Admin::PagesController < ApplicationController
  before_action :set_page, only: %i[ show edit update destroy ]

  # GET /admin/pages
  def index
    @pages = Page.all
  end

  # GET /admin/pages/1
  def show
  end

  # GET /admin/pages/new
  def new
    @page = Page.new
  end

  # GET /admin/pages/1/edit
  def edit
  end

  # POST /admin/pages
  def create
    @page = Page.new(page_params)

    if @page.save
      redirect_to [:admin, @page], notice: "Page was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /admin/pages/1
  def update
    if @page.update(page_params)
      redirect_to [:admin, @page], notice: "Page was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /admin/pages/1
  def destroy
    @page.destroy!
    redirect_to admin_pages_path, notice: "Page was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_page
      @page = Page.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def page_params
      params.expect(page: [ :title, :slug, :body ])
    end
end
