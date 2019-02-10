$(function() {
  var app = {
    handleView: function(e) {
      e.preventDefault();
      var $overlay = $(e.target).parent().next();
      var $form = $overlay.next();
      var height = $(document).scrollTop();

      $form.css('top', String(height + 50) + 'px');
      $overlay.show();
      $form.show();
    },
    handleExit: function(e) {
      var $form = $(e.target).parent();
      var $overlay = $form.prev();

      $form.hide();
      $overlay.hide();
    },
    bindEvents: function() {
      $('.testimonial').on('click', 'button', this.handleView.bind(this));
      $('.exit').on('click', this.handleExit.bind(this));
    },
    setPublishedColor: function() {
      $('.published').each(function(_, dd) {
        var $dd = $(dd);
        if ($dd.text() === 'false') {
          $dd.css('color', 'red');
        } else {
          $dd.css('color', '#8dcf0e');
        }
      });
    },
    init: function() {
      this.bindEvents();
      this.setPublishedColor();
    }
  };

  app.init();
});
