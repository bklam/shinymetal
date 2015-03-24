class UserKeysController < ApplicationController
  before_action :check_login
  before_action :set_user_key, except: [:index, :own_user_keys, :new,
                                        :create]
  
  # add_comment gets it own method because comments.build overwrites added comment with blank comment.
  # Use 'after_action' so that the blank comment, added to @user_key, isn't saved when during set_as_submitted action.
  after_action :build_empty_comment, except: [:index, :own_user_keys, :new,
                                               :create, :add_comment]
  
  # CanCan checks
  authorize_resource

  # GET /user_keys
  def index
    # Staffmember only wants to see key applications that have been submitted.
    @user_keys = UserKey.submitted.by_user.page(params[:page])
  end
  
  # GET /own_user_keys
  def own_user_keys
    # Any logged-in user can see all of their own keys.
    @user_keys = @current_user.user_keys.page(params[:page])
  end

  # GET /user_keys/1
  def show
  end

  # GET /user_keys/new
  def new
    @user_key = UserKey.new
  end

  # GET /user_keys/1/edit
  def edit
  end

  # POST /user_keys
  def create
    # Set user_key's user to be the current user
    params[:user_key][:user_id] = @current_user.id
    @user_key = UserKey.new(create_user_key_params)
    if @user_key.save
      redirect_to @user_key, notice: 'User key was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /user_keys/1
  def update
    if @current_user.role? :admin
      # Admin is allowed to add filters, orgs, active, etc.
      whitelist = admin_update_user_key_params
    else
      # The key's owner can change the application text if it hasn't been submitted yet
      whitelist = update_user_key_params
    end
    if @user_key.update(whitelist)
      redirect_to @user_key, notice: 'User key was successfully updated.'
    else
      render :edit
    end
  end
  
  # PATCH/PUT /user_keys/1/add_comment
  def add_comment
    # Set user_id of new comment to current user's id.
    # This takes the single nested comment_attribute;
    # always set the commenter's id to the current user's id.
    params[:user_key][:comments_attributes]["0"][:user_id] = @current_user.id
    # FIXME Adding a user_key_comment note from administrator should send email to requester?
    if @user_key.update(comment_user_key_params)
      redirect_to @user_key, notice: 'Comment was successfully added.'
    else
      render :show
    end
  end
  
  # DELETE /user_keys/1/delete_comment/1
  def delete_comment
    # Delete single comment;
    # It should usually be the case that comment cannot be deleted
    # if role? requester and at_stage? :awaiting_submission stage,
    # Since admin can't see the comments
    # FIXME: should this be validated?
    @bad_comment = Comment.find(params[:comment_id])
    @bad_comment.destroy
    redirect_to @user_key, notice: 'Comment was successfully deleted.'
  end

  # DELETE /user_keys/1
  def destroy
    @user_key.destroy
    redirect_to user_keys_url, notice: 'User key was successfully destroyed.'
  end
  
  # PATCH/PUT /user_keys/1/set_as_submitted
  def set_as_submitted
    if @user_key.set_status_as :awaiting_filters
      # Email confirmation and page confirmation
      UserKeyMailer.submitted_msg(@current_user).deliver
      redirect_to @user_key, notice: 'User key request was successfully submitted.'
    else
      render :show
    end
  end
  
  # PATCH/PUT /user_keys/1/set_as_filtered
  def set_as_filtered
    if @user_key.set_status_as :awaiting_confirmation
      redirect_to @user_key, notice: 'User key has had its filters assigned and is now visible to approvers.'
    else
      render :show
    end
  end
  
  # PATCH/PUT /user_keys/1/set_as_approved
  def set_as_confirmed
    if @user_key.set_status_as :confirmed
      redirect_to @user_key, notice: 'User key was successfully confirmed. All steps are complete.'
    else
      render :show
    end
  end
  
  # PATCH/PUT /user_keys/1/set_as_reset
  def set_as_reset
    if @user_key.set_status_as :awaiting_submission
      redirect_to user_keys_url, notice: 'User key application was successfully returned to the requester with comments,
                                          and is no longer visible to staff.'
    else
      render :show
    end
  end
  
  # PATCH/PUT /user_keys/1/approve_key/
  def approve_key
    if @user_key.set_approved_by(current_user)
      redirect_to @user_key, notice: 'You have successfully approved this key.'
    else
      render :show
    end
  end
  
  # PATCH/PUT /user_keys/1/undo_approve_key/
  def undo_approve_key
    if @user_key.undo_set_approved_by(current_user)
      redirect_to @user_key, notice: 'You have successfully revoked your approval for this key.'
    else
      render :show
    end
  end

  private
    def build_empty_comment
      # Build a blank comment form.
      # Overwrites any new comment passed in, so don't use for add_comment.
      @comment = @user_key.comments.build
    end
  
    def get_comments
      @public_comments = @user_key.comments.public_only.chronological
      @private_comments = @user_key.comments.private_only.chronological
    end
      
    def set_user_key
      @user_key = UserKey.find(params[:id])
      # Always pair the userkey object with its existing comments
      get_comments
    end

    def create_user_key_params # Seperate, due to new and permanent user_id
      params.require(:user_key).permit(:user_id, :name, :agree, :proposal_text_one, :proposal_text_two,
                                       :proposal_text_three, :proposal_text_four,
                                       :proposal_text_five, :proposal_text_six,
                                       :proposal_text_seven, :proposal_text_eight)
    end
    
    def update_user_key_params # For requester, upon updating application text
      
      params.require(:user_key).permit(:agree, :name, :proposal_text_one, :proposal_text_two,
                                       :proposal_text_three, :proposal_text_four,
                                       :proposal_text_five, :proposal_text_six,
                                       :proposal_text_seven, :proposal_text_eight)
    end
    
    def comment_user_key_params # For anyone who can comment
      params.require(:user_key).permit(:comments_attributes => [:id, :message, :public, :user_id])
    end
    
    def admin_update_user_key_params # For admin, upon updating filters or anything else
      params.require(:user_key).permit(:time_expired, :active, :reason,
                                       :filter_ids => [], :organization_ids => [])
    end
end
