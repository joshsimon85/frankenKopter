$(function() {
  var templates = {};
  var $main = $('main');

  templates.about = $('#about_template').html();
  templates.home = $('#home_template').html();
  templates.contact = $('#contact_template').html();

  $('[type="text/x-cutom-template"]').each(function(index, template) {
    $(template).remove();
  });

  var app = {
    removeActiveClass: function() {
      $('nav a').each(function(index, link) {
        $(link).removeClass('active');
      });
    },
    addActiveClass: function(index) {
      $('nav a').eq(index).addClass('active');
    },
    processClick: function(e) {
      e.preventDefault();
      var $this = $(e.target);

      this.removeActiveClass();
      if ($this.data('id') === 'home') {
        this.addActiveClass(0);
        $main.html(templates.home);
      } else if ($this.data('id') === 'about') {
        this.addActiveClass(1);
        $main.html(templates.about);
      } else {
        var $submit;

        this.addActiveClass(2);
        $main.html(templates.contact);
        $submit = $('[type="submit"]');
        $submit.prop('disabled', true);
      }
    },
    setHome: function() {
      $main.append(templates.home);
      $('nav a').eq(0).addClass('active');
    },
    isValidName: function(name) {
      return /[a-z]+/gi.test(name);
    },
    toggleErrorMessage: function(name, bool) {
      if (name === 'first_name') {
        $('.invalid_first').toggle(bool);
      } else {
        $('.invalid_last').toggle(bool);
      }
    },
    handleNameValidation: function($input, name, value) {
      if (!(this.isValidName(value))) {
        $input.addClass('invalid');
        this.toggleErrorMessage(name, true);
      } else {
        $input.removeClass('invalid');
        this.toggleErrorMessage(name, false);
      }
    },
    isValidEmail: function(email) {
      var reg = /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/;

      return reg.test(email);
    },
    handleEmailValidation: function($input, value) {
      var $invalidMessage = $('.invalid_email');
      if (!(this.isValidEmail(value))) {
        $input.addClass('invalid');
        $invalidMessage.show();
      } else {
        $input.removeClass('invalid');
        $invalidMessage.hide();
      }
    },
    isValidPhoneNumber: function(number) {
      if (/[a-z]/gi.test(number)) {
        return false;
      }

      return true;
    },
    handlePhoneValidation: function($input, value) {
      var $message = $('.invalid_number');

      if (value === '') {
        $input.removeClass('invalid');
        $message.hide();
      }

      if (!(this.isValidPhoneNumber(value))) {
        $input.addClass('invalid');
        $message.show();
      } else {
        $input.removeClass('invalid');
        $message.hide();
      }
    },
    isValidMessage: function(value) {
      var regex = /[a-z]+/gi;

      return regex.test(value) && value !== '';
    },
    handleMessageValidation: function($input, value) {
      var $message = $('.invalid_message');

      if (!(this.isValidMessage(value))) {
        $input.addClass('invalid');
        $message.show();
      } else {
        $input.removeClass('invalid');
        $message.hide();
      }
    },
    enableSubmitButton: function() {
      var invalidInputs = $('form input').filter(function(_, input) {
        return $(input).hasClass('invalid');
      });

      if (invalidInputs.length === 0 && $('form textarea').hasClass('invalid') === false) {
           $('input[type="submit"]').prop('disabled', false);
         }
    },
    validateInput: function(e) {
      var $input = $(e.target);
      var name = $input.attr('name');
      var value = $input.val();

      if (name === 'first_name' || name === 'last_name') {
        this.handleNameValidation($input, name, value);
      } else if (name === 'email') {
        this.handleEmailValidation($input, value);
      } else if (name === 'phone_number') {
        this.handlePhoneValidation($input, value);
      } else if (name === 'message') {
        this.handleMessageValidation($input, value);
      }

      this.enableSubmitButton();
      var invalidInputs = $('form input').filter(function(_, input) {
        return $(input).hasClass('invalid');
      });

      if (invalidInputs.length === 0 &&
         $('form textarea').hasClass('invalid') === false) {
           $('input[type="submit"]').prop('disabled', false);
         }
    },
    bindEvents: function() {
      $('nav').on('click', 'a', this.processClick.bind(this));
      $('body').on('focusout', 'input', this.validateInput.bind(this));
      $('body').on('focusout', 'textarea', this.validateInput.bind(this));
    },
    init: function() {
      this.bindEvents();
    },
  };

  app.init();
});
