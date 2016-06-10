(() => {
  // NOTE: only for linter and clarity:
  /* global _ */
  /* global _jed */
  const React = window.React
  const ReactDOM = window.ReactDOM
  const Autocomplete = window.ReactAutocomplete
  React.findDOMNode = ReactDOM.findDOMNode // NOTE: autocomplete lib needs this

  window.HandoverAutocomplete = React.createClass({
    propTypes: {
      placeholder: React.PropTypes.string.isRequired,
      onChange: React.PropTypes.func.isRequired,
      onSelect: React.PropTypes.func.isRequired,
      isLoading: React.PropTypes.bool.isRequired,
      searchResults: React.PropTypes.arrayOf(
        React.PropTypes.shape({
          name: React.PropTypes.string.isRequired,
          availability: React.PropTypes.string,
          type: React.PropTypes.string.isRequired,
          record: React.PropTypes.object.isRequired
        })
      )
    },

    getInitialState () {
      return { value: '' }
    },

    _handleChange (event, value) {
      // update internal state to reflect new input:
      this.setState({ value: value })
      // callback to controller:
      this.props.onChange(value)
    },

    _handleSelect (value, item) {
      // reset the input field
      this.setState({ value: '' })

      // callback
      this.props.onSelect(item)
    },

    // public methods
    resetInput () {
      // reset the input field
      this.setState({ value: '' })
    },

    // mirror jQueryAutocomplete API
    val (str) {
      this.setState({value: str})
    },

    // "partials"
    _renderMenu (items, value, givenStyles, props = this.props) {
      // show nothing when no search:
      if (value === '') {
        return <div style={{display: 'none'}}/>
      }

      const menuProps = {
        className: 'ui-autocomplete ui-autocomplete-scrollable ui-front ui-menu',
        style: {
          ...{ display: 'block', top: 'initial' },
          ...givenStyles
        }
      }

      if (props.isLoading) {
        return (<div {...menuProps}>
          <div className='loading-bg-small margin-top-m margin-bottom-m'/>
        </div>)
      }

      const models = _.sortBy(
        _.filter(items, (i) => i.props.item.type === _jed('Model')),
        (i) => i.props.item.name)

      const options = _.sortBy(
        _.filter(items, (i) => i.props.item.type === _jed('Option')),
        (i) => i.props.item.name)

      const templates = _.sortBy(
        _.filter(items, (i) => i.props.item.type === _jed('Template')),
        (i) => i.props.item.name)

      // searched but no results:
      if (props.searchResults && _.all([models, options, templates], _.isEmpty)) {
        return (<ul {...menuProps}>
          <li className='padding-left-s margin-top-m margin-bottom-m'>
            {_jed('No results')}
          </li>
        </ul>)
      }

      return (
        <ul {...menuProps}>

          {_.isEmpty(models) ? null
            : this._renderMenuSubSection(_jed('Models'), models)}

          {_.isEmpty(options) ? null
            : this._renderMenuSubSection(_jed('Options'), options)}

          {_.isEmpty(templates) ? null
            : this._renderMenuSubSection(_jed('Templates'), templates)}

        </ul>
      )
    },

    _renderMenuSubSection (heading, list, key) {
      return [
        (<li className='submenu-header' key={heading + "-header"}><b>{heading}</b></li>),
        (<li className='submenu-scroll' key={heading + "-list"}><ul>{list}</ul></li>)
      ]
    },

    _renderMenuItem (item, isHighlighted) {
      return (
        <li
          key={item.type + item.name + item.record.cid}
          item={item}
          id={item.abbr}
          className='separated-bottom exclude-last-child'>
          <a className={'row' + (!item.available ? ' light-red' : '')} title={item.name}>
            <div className='row'>
              <div className='col3of4' title={item.name}>
                <strong className='wrap'>{item.name}</strong>
              </div>
              <div className='col1of4 text-align-right'>
                <div className='row'>{item.availability}</div>
                <div className='row'>
                  <span className='grey-text'>{item.type}</span>
                </div>
              </div>
            </div>
          </a>
        </li>
      )
    },

    render () {
      const props = this.props

      var inputProps = {
        type: 'text',
        // TODO: id: 'assign-or-add-input'???
        className: 'row',
        placeholder: props.placeholder
      }

      var wrapperProps = {
        style: {}
      }

      return (
        <div>

          <Autocomplete
            ref='autocomplete'
            value={this.state.value}
            items={props.searchResults || []}
            wrapperProps={wrapperProps}
            inputProps={inputProps}
            renderMenu={this._renderMenu}
            selectOnInputClick={false}
            getItemValue={(item) => item.name}
            onSelect={this._handleSelect}
            onChange={this._handleChange}
            renderItem={this._renderMenuItem}
            />

        </div>
      )
    }
  })
})()
