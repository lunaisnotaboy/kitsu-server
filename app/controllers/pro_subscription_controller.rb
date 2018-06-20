class ProSubscriptionController < ApplicationController
  include CustomControllerHelpers

  before_action :authenticate_user!

  def stripe
    token = params[:token]
    customer = user.stripe_customer
    customer.source = token
    customer.save
    ProSubscription::StripeSubscription.create!(user: user)
    render status: 200
  end

  def ios
    # TODO: read iOS receipt and store enough data to verify with App Store servers
  end

  def destroy
    # TODO: read the pro subscription info and destroy it
  end

  def show
    # TODO: return the pro subscription
  end

  private

  def user
    current_user.resource_owner
  end
end
