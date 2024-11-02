# HTML Currency Input

It would be nice to have a browser-native locale aware currency input element:

```html
<input type=“currency” />
<input type="text" inputmode="currency” />
```

This element would render the amount using the user’s locale  ($1,234 or 1.234 €) while keeping a machine friendly number value when the form is submitted.

Are all the necessary pieces in place for a first class element? Maybe?

- navigator.language is widely available for locale information
- ISO 4217 defines currency codes by locale
- `Intl.NumberFormat` and `Number.prototype.toLocaleString` can format numbers as locale-aware currencies
- Web components can extend existing `HTMLInputElement`

## Cursor position is tricky

When a user edits currency, I expect locale specific separators (e.g. , or .) to be added. But this also causes the cursor to jump when the separator is added. This already happens for some customized elements for phone numbers or credit cards. Replacing the input’s value on change puts the cursor at the end of the input, while using setRangeText gives more control over where the cursor lands. Attempts to solve this programmatically with arithmetic on `input.selectionStart` and `input.selectionEnd` are brittle.

## Workaround

Similar to the approach detailed in the notes, I format as a currency when an input loses focus, and switch back to the raw value when the input is being edited. The increased complexity of maintaining cursor position was not worth the improvement in user experience.

<img src="/images/currency-input.gif" width="220" height="480" />

I think the separation of the numeric value for form submission from visual presentation is here. Trying to maintain the state of both through input.value isn’t sufficient. When inspecting the dom on an input element, you can see that it already uses user agent shadow content for showing the value.

## Code

I implemented this as a stimulus controller in https://jch.app, but here is an example without dependencies.

```html
<label>
  <p>Try entering some long and short numbers...</p>
  <input class="currency" inputmode="decimal" type="text" value="1234.56" style="padding: 0.5em; font-size: 1.2em">
</label>
```

```js
<script id="currencyJs" type="module">
  const iso_4217 = {
    'en-US': 'USD',
    'en-GB': 'GBP',
    'de-DE': 'EUR',
    'fr-FR': 'EUR',
    'es-ES': 'EUR',
    'it-IT': 'EUR',
    'ja-JP': 'JPY',
    'zh-CN': 'CNY',
    'ko-KR': 'KRW',
    'ru-RU': 'RUB',
    'ar-SA': 'SAR',
    'hi-IN': 'INR',
    'pt-BR': 'BRL',
    'tr-TR': 'TRY',
    'nl-NL': 'EUR',
    'pl-PL': 'PLN',
    'th-TH': 'THB',
    'vi-VN': 'VND',
    'id-ID': 'IDR',
    'ms-MY': 'MYR',
  };

  const CurrencyInput = class {
    constructor(element) {
      this.element = element;
      this.locale = navigator.language || navigator.userLanguage || 'en-US';
      this.element.addEventListener('blur', this.format.bind(this));
      this.element.addEventListener('focus', this.unformat.bind(this));
      this.format();
    }

    get formatter() {
      return new Intl.NumberFormat(this.locale, {
        style: "currency",
        currency: iso_4217[this.locale] || 'USD',
      });
    }

    format() {
      this.raw = this.element.value;

      if (!isNaN(this.element.value)) {
        this.element.value = this.formatter.format(this.element.value);
      }
    }

    unformat() {
      this.element.value = this.raw;
    }
  };

  new CurrencyInput(document.querySelector('.currency'));
</script>
```

## Notes

- https://html.spec.whatwg.org/multipage/form-control-infrastructure.html#concept-textarea/input-selection cursor position on input update
- Why not use a number input type? https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/number#using_number_inputs
- Format onblur, use real value when editing: https://levelup.gitconnected.com/creating-a-localized-currency-input-in-react-without-libraries-or-bugs-2f186124aedc?gi=b8408a661baa
- Cursor position arithmetic, too complex to maintain: https://stackoverflow.com/a/39279790
- https://github.com/toarm/number-format?tab=readme-ov-file web component for display, but not an extension on input
- https://github.com/IngressoRapidoWebComponents/money-input?tab=readme-ov-file web component on input, has cursor position issue
- https://devtoolstips.org/tips/en/inspect-user-agent-dom/
