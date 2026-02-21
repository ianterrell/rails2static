class Admin::PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /admin/posts
  def index
    @posts = Post.all
  end

  # GET /admin/posts/1
  def show
  end

  # GET /admin/posts/new
  def new
    @post = Post.new
  end

  # GET /admin/posts/1/edit
  def edit
  end

  # POST /admin/posts
  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to [:admin, @post], notice: "Post was successfully created."
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /admin/posts/1
  def update
    if @post.update(post_params)
      redirect_to [:admin, @post], notice: "Post was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /admin/posts/1
  def destroy
    @post.destroy!
    redirect_to admin_posts_path, notice: "Post was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :slug, :body, :published_at, :published ])
    end
end
