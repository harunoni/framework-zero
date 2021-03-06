//From http://stackoverflow.com/questions/13046401/how-to-set-selected-select-option-in-handlebars-template
//Update to work with Rhino which could not take a regex, or use jquery unlike many of the examples
Handlebars.registerHelper('upperCase', function(context) {
	if(context === undefined || context === null){
		return "";
	}

	/*! Case - v1.4.2 - 2016-11-11
	* Copyright (c) 2016 Nathan Bubna; Licensed MIT, GPL */
	(function() {
	    "use strict";
	    var unicodes = function(s, prefix) {
	        prefix = prefix || '';
	        return s.replace(/(^|-)/g, '$1\\u'+prefix).replace(/,/g, '\\u'+prefix);
	    },
	    basicSymbols = unicodes('20-26,28-2F,3A-40,5B-60,7B-7E,A0-BF,D7,F7', '00'),
	    baseLowerCase = 'a-z'+unicodes('DF-F6,F8-FF', '00'),
	    baseUpperCase = 'A-Z'+unicodes('C0-D6,D8-DE', '00'),
	    improperInTitle = 'A|An|And|As|At|But|By|En|For|If|In|Of|On|Or|The|To|Vs?\\.?|Via',
	    regexps = function(symbols, lowers, uppers, impropers) {
	        symbols = symbols || basicSymbols;
	        lowers = lowers || baseLowerCase;
	        uppers = uppers || baseUpperCase;
	        impropers = impropers || improperInTitle;
	        return {
	            capitalize: new RegExp('(^|['+symbols+'])(['+lowers+'])', 'g'),
	            pascal: new RegExp('(^|['+symbols+'])+(['+lowers+uppers+'])', 'g'),
	            fill: new RegExp('['+symbols+']+(.|$)','g'),
	            sentence: new RegExp('(^\\s*|[\\?\\!\\.]+"?\\s+"?|,\\s+")(['+lowers+'])', 'g'),
	            improper: new RegExp('\\b('+impropers+')\\b', 'g'),
	            relax: new RegExp('([^'+uppers+'])(['+uppers+']*)(['+uppers+'])(?=['+lowers+']|$)', 'g'),
	            upper: new RegExp('^[^'+lowers+']+$'),
	            hole: /[^\s]\s[^\s]/,
	            apostrophe: /'/g,
	            room: new RegExp('['+symbols+']')
	        };
	    },
	    re = regexps(),
	    _ = {
	        re: re,
	        unicodes: unicodes,
	        regexps: regexps,
	        types: [],
	        up: String.prototype.toUpperCase,
	        low: String.prototype.toLowerCase,
	        cap: function(s) {
	            return _.up.call(s.charAt(0))+s.slice(1);
	        },
	        decap: function(s) {
	            return _.low.call(s.charAt(0))+s.slice(1);
	        },
	        deapostrophe: function(s) {
	            return s.replace(re.apostrophe, '');
	        },
	        fill: function(s, fill) {
	            return !s || fill == null ? s : s.replace(re.fill, function(m, next) {
	                return next ? fill + next : '';
	            });
	        },
	        prep: function(s, fill, pascal, upper) {
	            if (!s){ return s || ''; }
	            if (!upper && re.upper.test(s)) {
	                s = _.low.call(s);
	            }
	            if (!fill && !re.hole.test(s)) {
	                var holey = _.fill(s, ' ');
	                if (re.hole.test(holey)) {
	                    s = holey;
	                }
	            }
	            if (!pascal && !re.room.test(s)) {
	                s = s.replace(re.relax, _.relax);
	            }
	            return s;
	        },
	        relax: function(m, before, acronym, caps) {
	            return before + ' ' + (acronym ? acronym+' ' : '') + caps;
	        }
	    },
	    Case = {
	        _: _,
	        of: function(s) {
	            for (var i=0,m=_.types.length; i<m; i++) {
	                if (Case[_.types[i]](s) === s){ return _.types[i]; }
	            }
	        },
	        flip: function(s) {
	            return s.replace(/\w/g, function(l) {
	                return (l == _.up.call(l) ? _.low : _.up).call(l);
	            });
	        },
	        random: function(s) {
	            return s.replace(/\w/g, function(l) {
	                return (Math.round(Math.random()) ? _.up : _.low).call(l);
	            });
	        },
	        type: function(type, fn) {
	            Case[type] = fn;
	            _.types.push(type);
	        }
	    },
	    types = {
	        lower: function(s, fill) {
	            return _.fill(_.low.call(_.prep(s, fill)), fill);
	        },
	        snake: function(s) {
	            return _.deapostrophe(Case.lower(s, '_'));
	        },
	        constant: function(s) {
	            return _.deapostrophe(Case.upper(s, '_'));
	        },
	        camel: function(s ) {
	            return _.decap(Case.pascal(s));
	        },
	        kebab: function(s) {
	            return _.deapostrophe(Case.lower(s, '-'));
	        },
	        upper: function(s, fill) {
	            return _.fill(_.up.call(_.prep(s, fill, false, true)), fill);
	        },
	        capital: function(s, fill) {
	            return _.fill(_.prep(s).replace(re.capitalize, function(m, border, letter) {
	                return border+_.up.call(letter);
	            }), fill);
	        },
	        pascal: function(s) {
	            return _.deapostrophe(_.fill(_.prep(s, false, true).replace(re.pascal, function(m, border, letter) {
	                return _.up.call(letter);
	            }), ''));
	        },
	        title: function(s) {
	            return Case.capital(s).replace(re.improper, function(small, p, i, s) {
	                return i > 0 && i < s.lastIndexOf(' ') ? _.low.call(small) : small;
	            });
	        },
	        sentence: function(s, names) {
	            s = Case.lower(s).replace(re.sentence, function(m, prelude, letter) {
	                return prelude + _.up.call(letter);
	            });
	            if (names) {
	                names.forEach(function(name) {
	                    s = s.replace(new RegExp('\\b'+Case.lower(name)+'\\b', "g"), _.cap);
	                });
	            }
	            return s;
	        }
	    };
	    
	    // TODO: Remove "squish" in a future breaking release.
	    types.squish = types.pascal;

	    for (var type in types) {
	        Case.type(type, types[type]);
	    }
	    // export Case (AMD, commonjs, or global)
	    var define = typeof define === "function" ? define : function(){};
	    define(typeof module === "object" && module.exports ? module.exports = Case : this.Case = Case);

	}).call(this);	
    return this.Case.upper(context.toString());
});
