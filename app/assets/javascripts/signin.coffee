$(document).ready ->
  loadSignUpForm();
  loadLoginForm();
  submitLoginUpForm();
  submitSignUpForm();
  submitPhoneForm();
  submitPhoneVerificationForm();
  facebookSignIn();
  logOut();
 
facebookSignIn = ->
  $('#fbSignIn').on 'click', ->
    FB.login ((response) ->
      if response.authResponse
        FB.api '/me?fields=email,name,picture', (responseFromFB) ->
          name = responseFromFB.name
          email = responseFromFB.email
          profile_picture =  responseFromFB.picture.data.url
          $.ajax
            type: 'POST'
            url: '/login'
            async: false
            data:
              'name': name
              'email': email
              'profile_picture': profile_picture
              'auth_provider': 'facebook'
            success: (data) ->
              submitPhoneForm();
            complete: ->
            error: (xhr, textStatus, errorThrown) ->
              console.log 'ajax loading error...'
              false
      else
        console.log 'The login failed because they were already logged in'
      return
    ), scope: 'email,public_profile'

logOut = ->
  $('#sign_out').click (e) ->
    FB.getLoginStatus (response) ->
      FB.logout() if response.authResponse
    true

loadLoginForm = ->
  $('a#haveAccount').click ->
    $.ajax
      type: 'GET'
      url: '/login'
      success: (data) ->
        loadSignUpForm();
        submitSignUpForm();
        facebookSignIn();
        submitPhoneForm();

loadSignUpForm = ->
  $('a#dontHaveAccount').click ->
    $.ajax
      type: 'GET'
      url: '/signup'
      success: (data) ->
        submitSignUpForm();
        loadLoginForm();
        facebookSignIn();
        submitPhoneForm();

submitLoginUpForm = ->
  $('#loginForm').submit (e) ->
    e.preventDefault()
    url = '/login'
    $.ajax
      type: 'POST'
      url: url
      data: $('#loginForm').serialize()
      success: (data) ->
        

submitSignUpForm = ->
  $('#signUpForm').submit (e) ->
    e.preventDefault()
    url = '/signup'
    $.ajax
      type: 'POST'
      url: url
      data: $('#signUpForm').serialize()
      success: (data) ->
        submitPhoneForm();
        submitPhoneVerificationForm();

submitPhoneForm = ->
  $('#phoneForm').submit (e) ->
    e.preventDefault()
    url = '/authenticate_phone'
    $.ajax
      type: 'POST'
      url: url
      data: $('#phoneForm').serialize()
      success: (data) ->
        submitPhoneVerificationForm();

submitPhoneVerificationForm = ->
  $('#verifyPhoneForm').submit (e) ->
    e.preventDefault()
    url = '/authenticate_phone'
    $.ajax
      type: 'POST'
      url: url
      data: $('#verifyPhoneForm').serialize()
      success: (data) ->