$(document).ready ->
	loadSignupModalFromLoginModal()
	submitSignUpForm()

loadSignupModalFromLoginModal = ->
	$('#dontHaveAccount').click ->
  	$('#loginModal').modal 'hide'
  	$('#signupModal').modal 'toggle'

submitSignUpForm = ->
	$('#newUser').submit (e) ->
		e.preventDefault()
		url = '/signup'
		$.ajax
		  type: 'POST'
		  url: url
		  data: $('#newUser').serialize()
		  success: (data) ->
		  	debugger
		  	if data == ""
		  		$('#signupModal').modal 'hide'
		  	else
		  		submitSignUpForm()
		   

