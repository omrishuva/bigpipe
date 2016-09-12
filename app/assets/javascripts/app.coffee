"use strict";
$(document).ready ->
  loadListeners();

loadListeners = ( exclude ) ->
  loadSignUpForm();
  loadLoginForm();
  loadPasswordRecoveryEmailForm();
  submitLoginForm();
  submitSignUpForm();
  submitPhoneForm();
  submitPhoneVerificationForm();
  submitPasswordRecoveryEmailForm();
  submitSelectNewPasswordForm();
  facebookSignIn();
  resendPhoneNumber();
  onFileUpload();
  hideNavsOnScroll();
  # createNewActivty();
  logOut();

document.addEventListener 'ajaxRequest',(e) ->
  ajaxRequest( e.detail.requestMethod, e.detail.url );

document.addEventListener 'setBodyBackgroundImage',(e) ->
  setBodyBackgroundImage( e.detail.imageUrl );

document.addEventListener 'setHomePageBackgroundImage',(e) ->
  setHomePageBackgroundImage( e.detail.imageUrl );

document.addEventListener 'RequestCreateTrip',(e) ->
  RequestCreateTrip();

showLoader = ->
  $('.signinLoader').show()

hideLoader = ->
   $('.signinLoader').hide()

setBodyBackgroundImage = ( imageUrl ) ->
  $("body").css("background", "url(#{imageUrl})" );

setHomePageBackgroundImage = (imageUrl) ->
  $("#imageBackground").css( "background", "url(#{imageUrl})" )

hideNavsOnScroll = -> 
  $(window).scroll ->
  if $(this).scrollTop() > 25
    $('.userSideBar').css 'display': 'none'

facebookSignIn = ->
  $('#fbSignIn, #fbTrainerSignIn').on 'click', ->
    FB.login ((response) ->
      showLoader() unless window.location.pathname == "/service_provider/onboarding";
      if response.authResponse
        FB.api '/me?fields=email,name,picture', (responseFromFB) ->
          name = responseFromFB.name
          email = responseFromFB.email
          profile_picture =  responseFromFB.picture.data.url
          url = if window.location.pathname == "/service_provider/onboarding"  then "/service_provider/onboarding" else "/login"
          $.ajax
            type: 'POST'
            url: url
            async: false
            data:
              'name': name
              'email': email
              'profile_picture': profile_picture
              'auth_provider': 'facebook'
            success: (data) ->
              if window.location.pathname == "/service_provider/onboarding"
                window.location.pathname = "/me"
              else
                postSignUp();
            complete: ->
            error: (xhr, textStatus, errorThrown) ->
              console.log 'ajax loading error...'
              false
      else
        console.log 'The login failed because they were already logged in'
      return
    ), scope: 'email,public_profile'

submitSignUpForm = ->
  $('#signUpForm').submit (e) ->
    disableSubmitButton();
    showLoader();
    e.preventDefault()
    url = '/signup'
    $.ajax
      type: 'POST'
      url: url
      data: $('#signUpForm').serialize()
      success: (data) ->
        postSignUp();

currentUserId = ->
  localStorage.getItem('currentUserId')

postSignUp = ->
  if localStorage.getItem("createNewActivty") == "true"
    localStorage.removeItem("createNewActivty")
    $.ajax
        type: 'POST'
        url: "/new_activity"
    # window.location.href = "/new_activity"
  else
    loadListeners();

createNewActivty = ->
  $('#createNewActivty').click (e) ->
    userId = e.target.dataset.userId
    if userId == undefined || userId == ""
      localStorage.setItem("createNewActivty", true)
      openSignupModal();
    else
      showLoader();
      $.ajax
        type: 'POST'
        url: "/new_activity"

RequestCreateTrip = ->
  $('#createTripPlan, #requestTripPlan').click (e) ->
    userId = e.target.dataset.userId
    # if userId == undefined || userId == ""
    #   openSignupModal();
    # else
    url = { "createTripPlan": '/new_trip', 'requestTripPlan': '/new_trip_request'  }
    showLoader();
    $.ajax
      type: 'POST'
      url: url[e.target.id]
      data: "new_trip"

ajaxRequest = ( requestMethod, url ) ->
  $.ajax
    type: requestMethod
    url: url

openSignupModal = ->
  $('.modal#signupModal').modal('toggle') 

submitLoginForm = ->
  $('#loginForm').submit (e) ->
    disableSubmitButton();
    showLoader();
    e.preventDefault()
    url = '/login'
    $.ajax
      type: 'POST'
      url: url
      data: $('#loginForm').serialize()
      success: (data) ->
        location.href = "/" if location.pathname.indexOf("/account/onboarding/")  != -1
        loadListeners();


logOut = ->
  $('#logout').click (e) ->
    localStorage.removeItem('currentUserId')
    location.reload();
    # FB.getLoginStatus (response) ->
    #   FB.logout() if response.authResponse
    # true
    localStorage.removeItem("currentUserId", null)

loadLoginForm = ->
  $('a#haveAccount').click ->
    $.ajax
      type: 'GET'
      url: '/login'
      success: (data) ->
        loadListeners();

loadSignUpForm = ->
  $('a#dontHaveAccount').click ->
    $.ajax
      type: 'GET'
      url: '/signup'
      success: (data) ->
       loadListeners();

submitPhoneForm = ->
  $('#phoneForm').submit (e) ->
    disableSubmitButton();
    showLoader();
    e.preventDefault()
    url = '/authenticate_phone'
    $.ajax
      type: 'POST'
      url: url
      data: $('#phoneForm').serialize()
      success: (data) ->
        loadListeners();

submitPhoneVerificationForm = ->
  $('#verifyPhoneForm').submit (e) ->
    disableSubmitButton();
    showLoader();
    e.preventDefault()
    url = '/authenticate_phone'
    $.ajax
      type: 'POST'
      url: url
      data: $('#verifyPhoneForm').serialize()
      success: (data) ->
        loadListeners();

resendPhoneNumber = ->
  $('a#resendPhoneNumber').click (e) ->
    showLoader();
    url = '/resend_phone_number'
    $.ajax
      type: 'GET'
      url: url
      success: (data) ->
        loadListeners();

loadPasswordRecoveryEmailForm = ->
  $('#forgotPassword').click (e) ->
    url = '/send_password_recovery_email'
    $.ajax
      type: 'GET'
      url: url
      success: (data) ->
       loadListeners();

submitPasswordRecoveryEmailForm = ->
  $('#passwordRecoveryEmail').submit (e) ->
    disableSubmitButton();
    showLoader();
    e.preventDefault()
    url = '/select_new_password'
    $.ajax
      type: 'GET'
      url: url
      data: $('#passwordRecoveryEmail').serialize()
      success: (data) ->
        loadListeners();

submitSelectNewPasswordForm = ->
  $('#selectNewPasswordForm').submit (e) ->
    e.preventDefault()
    disableSubmitButton();
    if $( "input[name='user[authentication_code]']" )[0].value != '' && $( "input[name='user[new_password]']" )[0].value != ''
      showLoader();
      url = '/set_new_password'
      $.ajax
        type: 'POST'
        url: url
        data: $('#selectNewPasswordForm').serialize()
        success: (data) ->
          loadListeners();
    else
      $('#selectNewPasswordForm').attr("disabled", false);

disableSubmitButton = ->
  $('.bthModalForm').attr("disabled", true); 

onFileUpload = ->
  $('.fileUploadInput').change (e) ->
    fileName = $(".fileUploadInput").val()
    splitedFileName = fileName.split("\\")
    fileName = splitedFileName[ (splitedFileName.length - 1) ]
    $('.fileName').text(fileName)
