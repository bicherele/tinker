/*
---

license: MIT-style license

authors:
  - Chiel Kunkels (@chielkunkels)

...
*/
!function(T){
	'use strict';

	T.Events.addEvent('layout.build', build);

	var form, fieldList, accountButtons, btnRegister, btnLogin;

	/**
	 *
	 */
	function build(){
		var userButton = new Element('a.account[href=#account][text=Account]');
		T.Layout.addToRegion(userButton, 'bl');
		var html = '<fieldset><ul><li><label>Username</label><input name="username"></li>'
			+'<li><label>Password</label><input name="password" type="password"></li>'
			+'<li id="accountButtons"><input id="btn-login" type="submit" class="button primary" value="Login">'
			+'<a id="btn-register" class="button">Register</a></li></ul></fieldset>';
		form = new Element('form', {action: '#login', html: html});
		var popover = new T.Popover(form, {button: userButton, anchor: 'bl'});

		fieldList = form.getElement('ul');
		accountButtons = $('accountButtons');
		btnLogin = $('btn-login');
		btnRegister = $('btn-register');

		form.addEvent('submit', function(e){
			e.preventDefault();
			var action = form.get('action');
			log(action);
			if (action === '#login'){
				login();
			} else if (action === '#register'){
				register();
			} else if (action === '#verify'){
				verify();
			}
		});

		btnRegister.addEvent('click', function(e){
			e.preventDefault();
			registerFields();
		});
	}

	/**
	 *
	 */
	function registerFields(){
		$$(
			new Element('li', {html: '<label>Repeat pass</label><input id="repeatPass" name="password-repeat" type="password">'}),
			new Element('li', {html: '<label>E-mail</label><input name="email" type="email">'})
		).inject(accountButtons, 'before');
		$('repeatPass').focus();
		form.set('action', '#register');
		btnLogin.set('value', 'Register');
		// Ugly hack, otherwise the popover closes, cause it thinks the button isn't inside the popover
		btnRegister.destroy.delay(1, btnRegister);
	}

	/**
	 *
	 */
	function login(){
		log('log in');

		new Request.JSON({
			url: '/login',
			data: form,
			method: 'post',
			onSuccess: function(){
				log(arguments);
			}
		}).send();
	}

	/**
	 *
	 */
	function register(){
		log('register');
		new Request.JSON({
			url: '/register',
			data: form,
			method: 'post',
			onSuccess: function(response){
				log(response);
				if (response.status === 'ok'){
					log('registration was successful. check email.');
				} else {
					log('stuff exploded, handle it!');
				}
			}
		}).send();
	}

}(typeof Tinker == 'undefined' ? (window.Tinker = {}) : Tinker);

