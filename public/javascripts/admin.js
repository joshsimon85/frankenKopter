$(function() {
  var $overlay = $('.overlay');
  var app = {
    handleView: function(e) {
      e.preventDefault();

      var $form = $(e.target).parent().next().find('.overlay-form');
      var height = $(document).scrollTop();

      $form.css('top', String(height + 30) + 'px');
      $overlay.show();
      $form.show();
    },
    handleExit: function(e) {
      e.stopPropagation();

      var $form = $(e.target).parent();

      $form.hide();
      $overlay.hide();
    },
    handleDelete: function(e) {
      var $section = $(e.target).closest('section').next();
      var $popup = $section.find('.popup');
      var height = $(document).scrollTop();

      $popup.css('top', String(height + 150) + 'px');
      $section.find('.popup-overlay').show();
      $popup.show();
    },
    handleCancel: function(e) {
      $(e.target).closest('section').find('.popup-overlay').hide();
      $(e.target).closest('section').find('.popup').hide();
    },
    handleBulkSubmit: function(e) {
      e.stopPropagation();
      var selectVal = $('[name="bulk_action"]').val();
      var $errorMsg = $('.bulk_actions .error_message');
      var $bulkViewed = $('.bulk_actions_viewed');
      var $bulkDelete = $('.bulk_actions_delete');

      $errorMsg.hide();

      if (selectVal === 'viewed' || selectVal ==='publish') {
        $overlay.show();
        $bulkViewed.show();
      } else if (selectVal === 'delete') {
        $overlay.show();
        $bulkDelete.show();
      } else {
        $errorMsg.show();
      }
    },
    handleBulkCancel: function(e) {
      e.stopPropagation();

      $('.bulk_actions_viewed, .bulk_actions_delete').hide();
      $overlay.hide();
    },
    bindEvents: function() {
      $('.testimonials, .emails').on('click', 'button', this.handleView.bind(this));
      $('.exit').on('click', this.handleExit.bind(this));
      $('.btn.danger').on('click', this.handleDelete.bind(this));
      $('.popup').on('click', this.handleCancel.bind(this));
      $('[name="bulk_submit"]').on('click', this.handleBulkSubmit.bind(this));
      $('[name="bulk_cancel"]').on('click', this.handleBulkCancel.bind(this));
    },
    setColor: function() {
      $('.published, .viewed').each(function(_, dd) {
        var $dd = $(dd);
        if ($dd.text() === 'false') {
          $dd.css('color', '#ff0000');
        } else {
          $dd.css('color', '#2e4313');
        }
      });
    },
    init: function() {
      this.bindEvents();
      this.setColor();
    }
  };

  app.init();
});
