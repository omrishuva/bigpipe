$(document).ready ->
 loadListeners();

loadListeners = ->
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
  onImageUpload();
  editUserABoutText();
  saveUserAboutText();
  cancelEditUserAboutText();
  changeUserNavTab();
  logOut();

showLoader = ->
  $('.signinLoader').show()

hideLoader = ->
   $('.signinLoader').hide()

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
                loadListeners();
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
        loadListeners();

loadSignUpForm = ->
  $('a#dontHaveAccount').click ->
    $.ajax
      type: 'GET'
      url: '/signup'
      success: (data) ->
       loadListeners();

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
       loadListeners();

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

onImageUpload = ->
  $('.imageUploadInput').change (e) ->
    formData = new FormData
    file = e.target.files[0]
    formData.append( 'image', file, file.name )
    $.ajax
        type: 'POST'
        url: '/upload_image'
        data: formData
        processData: false
        contentType: false
        success: (data) ->
          loadListeners();

editUserABoutText = ->
  $('#writeAboutYourself').click (e) ->
    $.ajax
        type: 'GET'
        url: 'edit_user_about_text'
        success: (data) ->
          loadListeners();

cancelEditUserAboutText = ->
  $('#cancelEditUserAboutText').click (e) ->
    CKEDITOR.instances.editor1.destroy();
    $('#editUserText').hide();
    $.ajax
        type: 'GET'
        url: 'cancel_user_edit_about_text'
        success: (data) ->
        loadListeners();

saveUserAboutText = ->
  $('#saveUserAboutText').click (e) ->
    
    userText = CKEDITOR.instances.editor1.getData()
    data = {}
    data['user_about_text'] = userText
    $.ajax
        type: 'POST'
        url: 'save_user_about_text'
        data: data
        success: (data) ->
          loadListeners();

changeUserNavTab = ->
  $('.userProfileNavItem').click (e) ->
    $("a#userNavTab.active").removeClass('active');
    $("a#userNavTab[name='#{e.target.name}']").addClass('active');
    $.ajax
        type: 'GET'
        url: "/me/nav/#{e.target.name}"
        # success: (data) ->
        #   loadListeners();