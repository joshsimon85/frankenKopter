$(function() {
  var $main = $('main');

  var app = {
    isValidName: function(name) {
      return /[a-z]+/gi.test(name);
    },
    toggleErrorMessage: function(name, bool) {
      if (name === 'first_name') {
        $('.session_invalid_first').hide();
        $('.invalid_first').toggle(bool);
      } else {
        $('.session_invalid_last').hide();
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
      var $message = $input.closest('dl').find('.invalid_text');

      $input.closest('dl').find('.session_invalid').hide();

      if (!(this.isValidEmail(value))) {
        $input.addClass('invalid');
        $message.show();
      } else {
        $input.removeClass('invalid');
        $message.hide();
      }
    },
    isValidPhoneNumber: function(number) {
      if (/[a-z]/gi.test(number)) {
        return false;
      }

      return true;
    },
    handlePhoneValidation: function($input, value) {
      var $message = $input.closest('dl').find('.invalid_text');

      $input.closest('dl').find('.session_invalid').hide();

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
      var $message = $input.closest('dl').find('.invalid_text');
      $input.closest('dl').find('.session_invalid').hide();

      if (!(this.isValidMessage(value))) {
        $input.css('border', '1px solid red');
        $message.show();
      } else {
        $input.css('border', '1px solid #cecece');
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
      }
    },
    validateMessage: function(e) {
      var text = $(e.target).text();
      var $input = $(e.target);
      var content = e.target.innerHTML;

      this.handleMessageValidation($input, text);
      $('[name="message"]').val(content);
    },
    styleEditor: function(e) {
      $(e.target).css('border', '1px solid #8dcf0e');
    },
    bindEvents: function() {
      $('body').on('focusout', 'input', this.validateInput.bind(this));
      $('body').on('focusout', '#editor', this.validateMessage.bind(this));
      $('body').on('focusin', '#editor', this.styleEditor.bind(this));
    },
    init: function() {
      this.bindEvents();
      $('[name="message"]').hide();
    },
  };

  app.init();
});
