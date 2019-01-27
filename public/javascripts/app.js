$(function() {
  var $main = $('main');

  var app = {
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
    },
    bindEvents: function() {
      $('body').on('focusout', 'input', this.validateInput.bind(this));
      $('body').on('focusout', 'textarea', this.validateInput.bind(this));
    },
    init: function() {
      this.bindEvents();
    },
  };

  app.init();
});
