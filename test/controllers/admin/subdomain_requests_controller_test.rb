require "test_helper"

class Admin::SubdomainRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:public)
    @user.update(global_admin: true)
    @public_subdomain = @user.subdomain
    @restarone_subdomain = Subdomain.find_by(name: 'restarone').name
    Apartment::Tenant.switch @restarone_subdomain do
      @restarone_user = User.find_by(email: 'contact@restarone.com')
    end
    @subdomain_request = subdomain_requests(:default)
  end


  test 'allows #index if global admin from public schema' do
    assert @user.global_admin
    sign_in(@user)
    get admin_subdomain_requests_url
    assert_response :success
    assert_template :index
  end

  test 'denies #index if spoofed global admin' do
    @restarone_user.update(global_admin: true)
    Apartment::Tenant.switch @restarone_subdomain do
      begin
        sign_in(@restarone_user)
        get admin_subdomain_requests_url
        rescue ActionController::RoutingError => e
          assert e.message
      else
        raise StandardError.new "ActionController::RoutingError NOT RAISED!"
      end
    end
  end

  test 'denies #index if not global admin' do      
    @user.update(global_admin: false)
    begin
        refute @user.global_admin
        sign_in(@user)
        get admin_subdomain_requests_url
    rescue ActionController::RoutingError => e
        assert e.message
    else
      raise StandardError.new "ActionController::RoutingError NOT RAISED!"
    end
  end

  test 'allows #edit if global admin' do
    sign_in(@user)
    get edit_admin_subdomain_request_url(id: @subdomain_request.id)
    assert_response :success
    assert_template :edit
  end

  test 'denies #edit if not global admin' do
    @user.update(global_admin: false)
    begin
      refute @user.global_admin
      sign_in(@user)
      get edit_admin_subdomain_request_url(id: @subdomain_request.id)
      rescue ActionController::RoutingError => e
        assert e.message
    else
      raise StandardError.new "ActionController::RoutingError NOT RAISED!"
    end
  end

  test 'allows #show if global admin' do
    sign_in(@user)
    get admin_subdomain_request_url(id: @subdomain_request.id)
    assert_response :success
    assert_template :show
  end

  test 'denies #show if not global admin' do
    @user.update(global_admin: false)
    begin
      refute @user.global_admin
      sign_in(@user)
      get admin_subdomain_request_url(id: @subdomain_request.id)
      rescue ActionController::RoutingError => e
        assert e.message
    else
      raise StandardError.new "ActionController::RoutingError NOT RAISED!"
    end
  end

  test 'allows #update if global admin' do
    sign_in(@user)
    patch admin_subdomain_request_url(id: @subdomain_request.id)
    assert_response :success
    assert_template :update
  end

  test 'denies #update if not global admin' do
    @user.update(global_admin: false)
    begin
      sign_in(@user)
      patch admin_subdomain_request_url(id: @subdomain_request.id)
      rescue ActionController::RoutingError => e
        assert e.message
    else
      raise StandardError.new "ActionController::RoutingError NOT RAISED!"
    end
  end

  test 'allows #destroy if global admin' do
    sign_in(@user)
    delete admin_subdomain_request_url(id: @subdomain_request.id)
    assert_response :success
  end

  test 'denies #destroy if not global admin' do
    @user.update(global_admin: false)
    begin
      sign_in(@user)
      delete admin_subdomain_request_url(id: @subdomain_request.id)
      rescue ActionController::RoutingError => e
        assert e.message
    else
      raise StandardError.new "ActionController::RoutingError NOT RAISED!"
    end
  end
end
