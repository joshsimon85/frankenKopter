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
    handleDelete: function(e) {
      var $testimonial = $(e.target).closest('.testimonial');
      $testimonial.find('.popup-overlay').show();
      $testimonial.find('.popup').show();
    },
    handleCancel: function(e) {
      $(e.target).closest('.testimonial').find('.popup-overlay').hide();
      $(e.target).closest('.testimonail').find('.popup').hide();
    },
    bindEvents: function() {
      $('.testimonial').on('click', 'button', this.handleView.bind(this));
      $('.exit').on('click', this.handleExit.bind(this));
      $('.delete').on('click', this.handleDelete.bind(this));
      $('.popup').on('click', this.handleCancel.bind(this));
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
