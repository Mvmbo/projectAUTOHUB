/* =============================================================
   AutoHUB – Validazione form client-side (italiano)
   ============================================================= */

(function () {
  'use strict';

  function getField(id) { return document.getElementById(id); }

  function showError(fieldId, message) {
    var field = getField(fieldId);
    var errEl = getField(fieldId + '-error');
    if (field) field.classList.add('error-field');
    if (errEl) errEl.textContent = message;
    return false;
  }

  function clearError(fieldId) {
    var field = getField(fieldId);
    var errEl = getField(fieldId + '-error');
    if (field) field.classList.remove('error-field');
    if (errEl) errEl.textContent = '';
  }

  var PATTERNS = {
    username: /^[a-zA-Z0-9_]{3,30}$/,
    email:    /^[\w.+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/,
    phone:    /^[+\d\s\-()\/.]{7,20}$/,
    postal:   /^[A-Z0-9\s\-]{3,10}$/i,
    cardNum:  /^\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}$/,
    expiry:   /^(0[1-9]|1[0-2])\/\d{2}$/,
    cvv:      /^\d{3,4}$/,
    price:    /^\d+(\.\d{1,2})?$/
  };

  function validateUsername(val) {
    if (!val) return 'Username obbligatorio.';
    if (!PATTERNS.username.test(val)) return 'Username: 3-30 caratteri, solo lettere, numeri e underscore.';
    return '';
  }

  function validateEmail(val) {
    if (!val) return 'Indirizzo email obbligatorio.';
    if (!PATTERNS.email.test(val)) return 'Inserisci un indirizzo email valido.';
    return '';
  }

  function validatePassword(val) {
    if (!val) return 'Password obbligatoria.';
    if (val.length < 8) return 'La password deve avere almeno 8 caratteri.';
    return '';
  }

  function validateRequired(val, label) {
    if (!val || val.trim() === '') return (label || 'Questo campo') + ' è obbligatorio.';
    return '';
  }

  function validatePhone(val) {
    if (!val) return '';
    if (!PATTERNS.phone.test(val)) return 'Inserisci un numero di telefono valido.';
    return '';
  }

  function validatePostal(val) {
    if (!val) return 'CAP obbligatorio.';
    if (!PATTERNS.postal.test(val)) return 'Inserisci un CAP valido.';
    return '';
  }

  function validatePrice(val) {
    if (!val) return 'Prezzo obbligatorio.';
    if (!PATTERNS.price.test(val) || parseFloat(val) <= 0) return 'Inserisci un prezzo valido (es. 1500.00).';
    return '';
  }

  function onFieldChange(id, validatorFn) {
    var el = getField(id);
    if (!el) return;
    el.addEventListener('change', function () {
      var err = validatorFn(el.value.trim());
      if (err) showError(id, err); else clearError(id);
    });
    el.addEventListener('blur', function () {
      var err = validatorFn(el.value.trim());
      if (err) showError(id, err); else clearError(id);
    });
  }

  function initRegisterForm() {
    var form = getField('registerForm');
    if (!form) return;

    onFieldChange('username', validateUsername);
    onFieldChange('email', validateEmail);
    onFieldChange('password', validatePassword);
    onFieldChange('fullName', function(v){ return validateRequired(v, 'Nome completo'); });
    onFieldChange('phone', validatePhone);

    function validateConfirmPwd(val) {
      var pwd = getField('password');
      if (!val) return 'Conferma la password.';
      if (pwd && val !== pwd.value) return 'Le password non coincidono.';
      return '';
    }
    onFieldChange('confirmPassword', validateConfirmPwd);

    form.addEventListener('submit', function (e) {
      var valid = true;
      var username = getField('username');
      var email = getField('email');
      var password = getField('password');
      var confirmPwd = getField('confirmPassword');
      var fullName = getField('fullName');
      var err;

      err = validateUsername(username ? username.value.trim() : '');
      if (err) { showError('username', err); valid = false; } else clearError('username');

      err = validateEmail(email ? email.value.trim() : '');
      if (err) { showError('email', err); valid = false; } else clearError('email');

      err = validatePassword(password ? password.value : '');
      if (err) { showError('password', err); valid = false; } else clearError('password');

      if (password && confirmPwd) {
        if (!confirmPwd.value) {
          showError('confirmPassword', 'Conferma la password.'); valid = false;
        } else if (confirmPwd.value !== password.value) {
          showError('confirmPassword', 'Le password non coincidono.'); valid = false;
        } else clearError('confirmPassword');
      }

      err = validateRequired(fullName ? fullName.value.trim() : '', 'Nome completo');
      if (err) { showError('fullName', err); valid = false; } else clearError('fullName');

      if (!valid) e.preventDefault();
    });
  }

  function initLoginForm() {
    var form = getField('loginForm');
    if (!form) return;

    onFieldChange('username', function(v){ return validateRequired(v, 'Username'); });
    onFieldChange('password', function(v){ return validateRequired(v, 'Password'); });

    form.addEventListener('submit', function (e) {
      var valid = true;
      var username = getField('username');
      var password = getField('password');

      var err = validateRequired(username ? username.value.trim() : '', 'Username');
      if (err) { showError('username', err); valid = false; } else clearError('username');

      err = validateRequired(password ? password.value : '', 'Password');
      if (err) { showError('password', err); valid = false; } else clearError('password');

      if (!valid) e.preventDefault();
    });
  }


})();
