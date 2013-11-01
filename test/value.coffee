OldValue = require('../lib/autoprefixer/old-value')
Value    = require('../lib/autoprefixer/value')
parse    = require('postcss/lib/parse')

describe 'Value', ->
  beforeEach ->
    @calc = new Value('calc', ['-moz-', '-ms-'])

  describe '.save()', ->

    it 'clones declaration', ->
      css   = parse('a { prop: v }')
      width = css.rules[0].decls[0]

      width._autoprefixerValues = { '-ms-': '-ms-v' }
      Value.save(width)

      css.toString().should.eql('a { prop: -ms-v; prop: v }')

    it 'updates declaration with prefix', ->
      css   = parse('a { -ms-prop: v }')
      width = css.rules[0].decls[0]

      width._autoprefixerValues = { '-ms-': '-ms-v' }
      Value.save(width)

      css.toString().should.eql('a { -ms-prop: -ms-v }')

    it 'ignores on another prefix property', ->
      css   = parse('a { -ms-prop: v; prop: v }')
      width = css.rules[0].decls[1]

      width._autoprefixerValues = { '-ms-': '-ms-v' }
      Value.save(width)

      css.toString().should.eql('a { -ms-prop: v; prop: v }')

  describe 'check()', ->

    it 'checks value in string', ->
      css = parse('a { 0: calc(1px + 1em); ' +
                      '1: 1px calc(1px + 1em); ' +
                      '2: (calc(1px + 1em)); ' +
                      '3: -ms-calc; ' +
                      '4: calced; }')

      @calc.check(css.rules[0].decls[0]).should.be.true
      @calc.check(css.rules[0].decls[1]).should.be.true
      @calc.check(css.rules[0].decls[2]).should.be.true

      @calc.check(css.rules[0].decls[3]).should.be.false
      @calc.check(css.rules[0].decls[4]).should.be.false

  describe 'old()', ->

    it 'check prefixed value', ->
      @calc.old('-ms-').should.eql new OldValue('-ms-calc')

  describe 'replace()', ->

    it 'adds prefix to value', ->
      @calc.replace('1px calc(1em)', '-ms-').should.eql('1px -ms-calc(1em)')
      @calc.replace('1px,calc(1em)', '-ms-').should.eql('1px,-ms-calc(1em)')

  describe 'process()', ->

    it 'adds prefixes', ->
      css   = parse('a { width: calc(1em) calc(1%) }')
      width = css.rules[0].decls[0]

      @calc.process(width)
      width._autoprefixerValues.should.eql
        '-moz-': '-moz-calc(1em) -moz-calc(1%)'
        '-ms-':   '-ms-calc(1em) -ms-calc(1%)'

    it 'checks parents prefix', ->
      css   = parse('::-moz-fullscreen a { width: calc(1%) }')
      width = css.rules[0].decls[0]

      @calc.process(width)
      width._autoprefixerValues.should.eql
        '-moz-': '-moz-calc(1%)'
