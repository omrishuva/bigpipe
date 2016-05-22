$(document).ready ->
  loadSignUpForm();
  loadLoginForm();
  submitSignUpForm();
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
          #Take the vales and send to
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
              $('#fbSignIn').hide()
              $('#signupModal').modal 'hide'
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

loadSignUpForm = ->
  $('a#dontHaveAccount').click ->
    $.ajax
      type: 'GET'
      url: '/signup'
      success: (data) ->
        if data == ""
        else
          loadLoginForm();
          submitSignUpForm();

submitSignUpForm = ->
  $('#signUpForm').submit (e) ->
    e.preventDefault()
    url = '/signup'
    $.ajax
      type: 'POST'
      url: url
      data: $('#newUser').serialize()
      success: (data) ->
        if data == ""
          $('#signupModal').modal 'hide'
        else
          submitSignUpForm()