!function(e){function t(t){for(var r,a,s=t[0],c=t[1],u=t[2],l=0,p=[];l<s.length;l++)a=s[l],Object.prototype.hasOwnProperty.call(o,a)&&o[a]&&p.push(o[a][0]),o[a]=0;for(r in c)Object.prototype.hasOwnProperty.call(c,r)&&(e[r]=c[r]);for(d&&d(t);p.length;)p.shift()();return i.push.apply(i,u||[]),n()}function n(){for(var e,t=0;t<i.length;t++){for(var n=i[t],r=!0,s=1;s<n.length;s++){var c=n[s];0!==o[c]&&(r=!1)}r&&(i.splice(t--,1),e=a(a.s=n[0]))}return e}var r={},o={2:0},i=[];function a(t){if(r[t])return r[t].exports;var n=r[t]={i:t,l:!1,exports:{}};return e[t].call(n.exports,n,n.exports,a),n.l=!0,n.exports}a.m=e,a.c=r,a.d=function(e,t,n){a.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:n})},a.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},a.t=function(e,t){if(1&t&&(e=a(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var n=Object.create(null);if(a.r(n),Object.defineProperty(n,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var r in e)a.d(n,r,function(t){return e[t]}.bind(null,r));return n},a.n=function(e){var t=e&&e.__esModule?function(){return e["default"]}:function(){return e};return a.d(t,"a",t),t},a.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},a.p="";var s=window.webpackJsonp=window.webpackJsonp||[],c=s.push.bind(s);s.push=t,s=s.slice();for(var u=0;u<s.length;u++)t(s[u]);var d=c;i.push([631,0]),n()}({141:function(e,t,n){"use strict";t.__esModule=!0,t.SettingsPanel=t.settingsReducer=t.settingsMiddleware=t.useSettings=void 0;var r=n(639);t.useSettings=r.useSettings;var o=n(640);t.settingsMiddleware=o.settingsMiddleware;var i=n(641);t.settingsReducer=i.settingsReducer;var a=n(643);t.SettingsPanel=a.SettingsPanel},142:function(e,t,n){"use strict";t.__esModule=!0,t.loadSettings=t.updateSettings=void 0;t.updateSettings=function(e){return void 0===e&&(e={}),{type:"settings/update",payload:e}};t.loadSettings=function(e){return void 0===e&&(e={}),{type:"settings/load",payload:e}}},143:function(e,t,n){"use strict";t.__esModule=!0,t.selectSettings=void 0;t.selectSettings=function(e){return null==e?void 0:e.settings}},144:function(e,t,n){"use strict";t.__esModule=!0,t.DEFAULT_PAGE=t.MESSAGE_TYPES=t.COMBINE_MAX_TIME_WINDOW=t.COMBINE_MAX_MESSAGES=t.MESSAGE_PRUNE_INTERVAL=t.MESSAGE_SAVE_INTERVAL=t.MAX_PERSISTED_MESSAGES=t.MAX_VISIBLE_MESSAGES=void 0;var r=n(646);function o(e,t){var n;if("undefined"==typeof Symbol||null==e[Symbol.iterator]){if(Array.isArray(e)||(n=function(e,t){if(!e)return;if("string"==typeof e)return i(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);"Object"===n&&e.constructor&&(n=e.constructor.name);if("Map"===n||"Set"===n)return Array.from(e);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return i(e,t)}(e))||t&&e&&"number"==typeof e.length){n&&(e=n);var r=0;return function(){return r>=e.length?{done:!0}:{done:!1,value:e[r++]}}}throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}return(n=e[Symbol.iterator]()).next.bind(n)}function i(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}t.MAX_VISIBLE_MESSAGES=2500;t.MAX_PERSISTED_MESSAGES=1e3;t.MESSAGE_SAVE_INTERVAL=1e4;t.MESSAGE_PRUNE_INTERVAL=6e4;t.COMBINE_MAX_MESSAGES=5;t.COMBINE_MAX_TIME_WINDOW=5e3;var a=[{type:"internal",name:"Internal Messages",description:"Internal tgchat messages.",important:!0},{type:"system",name:"System Messages",description:"Messages from your client, always enabled",selector:".boldannounce, .filter_system",important:!0},{type:"unknown",name:"Unsorted Messages",description:"Everything we could not sort, always enabled",important:!0},{type:"localchat",name:"Local",description:"In-character local messages (say, emote, etc)",selector:".filter_say, .say, .emote"},{type:"radio",name:"Radio",description:"All departments of radio messages",selector:".filter_radio, .alert, .syndradio, .centradio, .airadio, .entradio, .comradio, .secradio, .engradio, .medradio, .sciradio, .supradio, .srvradio, .expradio, .radio, .deptradio, .newscaster"},{type:"info",name:"Info",description:"Non-urgent messages from the game and items",selector:".filter_notice, .notice:not(.pm), .adminnotice, .info, .sinister, .cult"},{type:"warning",name:"Warnings",description:"Urgent messages from the game and items",selector:".filter_warning, .warning:not(.pm), .critical, .userdanger, .italics"},{type:"deadchat",name:"Deadchat",description:"All of deadchat",selector:".filter_deadsay, .deadsay"},{type:"ooc",name:"OOC",description:"The bluewall of global OOC messages",selector:".filter_ooc, .ooc"},{type:"adminpm",name:"Admin PMs",description:"Messages to/from admins (adminhelp)",selector:".filter_pm, .pm"},{type:"combat",name:"Combat Log",description:"Urist McTraitor has stabbed you with a knife!",selector:".filter_combat, .danger"},{type:"adminchat",name:"Admin Chat",description:"ASAY messages",selector:".filter_ASAY, .admin_channel",admin:!0},{type:"modchat",name:"Mod Chat",description:"MSAY messages",selector:".filter_MSAY, .mod_channel",admin:!0},{type:"eventchat",name:"Event Chat",description:"ESAY messages",selector:".filter_ESAY, .event_channel",admin:!0},{type:"adminlog",name:"Admin Log",description:"ADMIN LOG: Urist McAdmin has jumped to coordinates X, Y, Z",selector:".filter_adminlog, .log_message",admin:!0},{type:"attacklog",name:"Attack Log",description:"Urist McTraitor has shot John Doe",selector:".filter_attacklog",admin:!0},{type:"debuglog",name:"Debug Log",description:"DEBUG: SSPlanets subsystem Recover().",selector:".filter_debuglog",admin:!0}];t.MESSAGE_TYPES=a;var s={id:(0,r.createUuid)(),name:"Chat",acceptedTypes:function(){for(var e,t={},n=o(a);!(e=n()).done;){t[e.value.type]=!0}return t}(),count:0};t.DEFAULT_PAGE=s},145:function(e,t,n){"use strict";t.__esModule=!0,t.loadChat=t.updateMessageCount=t.changeChatPage=void 0;var r=n(75),o=(0,r.createAction)("chat/changePage");t.changeChatPage=o;var i=(0,r.createAction)("chat/updateMessageCount");t.updateMessageCount=i;var a=(0,r.createAction)("chat/load");t.loadChat=a},404:function(e,t,n){"use strict";t.__esModule=!0,t.audioReducer=t.NowPlayingWidget=t.audioMiddleware=t.useAudio=void 0;var r=n(635);t.useAudio=r.useAudio;var o=n(636);t.audioMiddleware=o.audioMiddleware;var i=n(638);t.NowPlayingWidget=i.NowPlayingWidget;var a=n(644);t.audioReducer=a.audioReducer},405:function(e,t,n){"use strict";t.__esModule=!0,t.selectAudio=void 0;t.selectAudio=function(e){return e.audio}},406:function(e,t,n){"use strict";t.__esModule=!0,t.chatReducer=t.chatMiddleware=t.ChatTabs=t.ChatPanel=void 0;var r=n(645);t.ChatPanel=r.ChatPanel;var o=n(647);t.ChatTabs=o.ChatTabs;var i=n(648);t.chatMiddleware=i.chatMiddleware;var a=n(649);t.chatReducer=a.chatReducer},407:function(e,t,n){"use strict";(function(e){t.__esModule=!0,t.chatRenderer=t.createReconnectedMessage=t.serializeMessage=t.createMessage=void 0;var r=n(384),o=n(6),i=n(23),a=n(144),s=n(99);function c(e,t){var n;if("undefined"==typeof Symbol||null==e[Symbol.iterator]){if(Array.isArray(e)||(n=function(e,t){if(!e)return;if("string"==typeof e)return u(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);"Object"===n&&e.constructor&&(n=e.constructor.name);if("Map"===n||"Set"===n)return Array.from(e);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return u(e,t)}(e))||t&&e&&"number"==typeof e.length){n&&(e=n);var r=0;return function(){return r>=e.length?{done:!0}:{done:!1,value:e[r++]}}}throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}return(n=e[Symbol.iterator]()).next.bind(n)}function u(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}var d=(0,i.createLogger)("chatRenderer"),l=function(e){return Object.assign({},e,{createdAt:Date.now()})};t.createMessage=l;t.serializeMessage=function(e){return{type:e.type,text:e.text,times:e.times,createdAt:e.createdAt}};t.createReconnectedMessage=function(){var e=document.createElement("div");return e.className="Chat__reconnected",l({type:"internal",text:"Reconnected",node:e})};var p=function(e){var t=e.node,n=e.times;if(t&&n){var r=t.querySelector(".Chat__badge"),i=r||document.createElement("div");i.textContent=n,i.className=(0,o.classes)(["Chat__badge","Chat__badge--animate"]),requestAnimationFrame((function(){i.className="Chat__badge"})),r||t.appendChild(i)}},g=function(){function t(){var e=this;this.rootNode=null,this.queue=[],this.messages=[],this.visibleMessages=[],this.page=a.DEFAULT_PAGE,this.events=new r.EventEmitter,this.subscribers={batchProcessed:[],scrollTrackingChanged:[]},this.scrollNode=null,this.scrollTracking=!0,this.handleScroll=function(t){var n=e.scrollNode,r=n.scrollHeight,o=n.scrollTop+n.offsetHeight,i=Math.abs(r-o)<32;i!==e.scrollTracking&&(e.scrollTracking=i,e.events.emit("scrollTrackingChanged",i),d.debug("tracking",e.scrollTracking))},this.ensureScrollTracking=function(){e.scrollTracking&&e.scrollToBottom()},setInterval((function(){return e.pruneMessages()}),a.MESSAGE_PRUNE_INTERVAL)}var n=t.prototype;return n.mount=function(t){var n=this;this.rootNode?t.appendChild(this.rootNode):this.rootNode=t,this.scrollNode=function(e){for(var t=document.body,n=e;n&&n!==t;){if(n.scrollWidth<n.offsetWidth)return n;n=n.parentElement}return window}(this.rootNode),this.scrollNode.addEventListener("scroll",this.handleScroll),e((function(){n.scrollToBottom()})),this.queue.length>0&&(this.processBatch(this.queue),this.queue=[])},n.assignStyle=function(e){void 0===e&&(e={}),Object.assign(this.rootNode.style,e)},n.scrollToBottom=function(){this.scrollNode.scrollTop=this.scrollNode.scrollHeight},n.changePage=function(e){this.page=e,this.rootNode.textContent="",this.visibleMessages=[];for(var t,n,r=document.createDocumentFragment(),o=c(this.messages);!(n=o()).done;){var i=n.value;(0,s.canPageAcceptType)(e,i.type)&&(t=i.node,r.appendChild(t),this.visibleMessages.push(i))}t&&(this.rootNode.appendChild(r),t.scrollIntoView())},n.getCombinableMessage=function(e){for(var t=Date.now(),n=this.visibleMessages.length,r=n-1,o=Math.max(0,n-a.COMBINE_MAX_MESSAGES),i=r;i>=o;i--){var s=this.visibleMessages[i];if(s.text===e.text&&t<s.createdAt+a.COMBINE_MAX_TIME_WINDOW)return s}return null},n.processBatch=function(t){var n=this;if(this.rootNode){for(var r,o,i=document.createDocumentFragment(),u={},d=c(t);!(o=d()).done;){var g=o.value,h=l(g),f=this.getCombinableMessage(h);if(f)f.times=(f.times||1)+1,p(f);else{if(h.node?r=h.node:((r=document.createElement("div")).innerHTML=h.text,h.node=r),!h.type){var m=a.MESSAGE_TYPES.find((function(e){return e.selector&&r.querySelector(e.selector)}));h.type=(null==m?void 0:m.type)||"unknown"}p(h),u[h.type]||(u[h.type]=0),u[h.type]+=1,this.messages.push(h),(0,s.canPageAcceptType)(this.page,h.type)&&(i.appendChild(r),this.visibleMessages.push(h))}}r&&(this.rootNode.appendChild(i),this.scrollTracking&&e((function(){return n.scrollToBottom()}))),this.events.emit("batchProcessed",u)}else for(var v,y=c(t);!(v=y()).done;){var S=v.value;this.queue.push(S)}},n.pruneMessages=function(){if(this.rootNode){var e=this.visibleMessages,t=Math.max(0,e.length-a.MAX_VISIBLE_MESSAGES);this.visibleMessages=e.slice(t);for(var n=0;n<t;n++){var r=e[n];this.rootNode.removeChild(r.node)}d.log("pruned "+t+" messages")}},t}();window.__chatRenderer__||(window.__chatRenderer__=new g);var h=window.__chatRenderer__;t.chatRenderer=h}).call(this,n(132).setImmediate)},408:function(e,t,n){"use strict";t.__esModule=!0,t.PingIndicator=t.pingMiddleware=t.pingReducer=t.selectPing=void 0;var r=n(0),o=n(650),i=n(14),a=n(1),s=n(2),c=n(42),u=function(e){return(null==e?void 0:e.ping)||{}};t.selectPing=u;t.pingReducer=function(e,t){void 0===e&&(e={});var n=t.type,r=t.payload;if("ping/success"===n){var o=r.roundtrip,a=e.roundtripAvg||o,s=Math.round(.4*a+.6*o);return{roundtrip:o,roundtripAvg:s,failCount:0,networkQuality:1-(0,i.scale)(s,50,200)}}if("ping/fail"===n){var c=e.failCount,u=void 0===c?0:c,d=(0,i.clamp01)(e.networkQuality-u/3),l=Object.assign({},e,{failCount:u+1,networkQuality:d});return u>3&&(l.roundtrip=undefined,l.roundtripAvg=undefined),l}return e};t.pingMiddleware=function(e){var t=!1,n=0,r=[],o=function(){for(var t=0;t<8;t++){var o=r[t];o&&Date.now()-o.sentAt>2e3&&(r[t]=null,e.dispatch({type:"ping/fail"}))}var i={index:n,sentAt:Date.now()};r[n]=i,(0,a.sendMessage)({type:"ping",payload:{index:n}}),n=(n+1)%8};return function(e){return function(n){var i=n.type,a=n.payload;if(t||(t=!0,setInterval(o,2500),o()),"pingReply"===i){var s=a.index,c=r[s];if(!c)return;return r[s]=null,e(function(e){var t=.5*(Date.now()-e.sentAt);return{type:"ping/success",payload:{lastId:e.id,roundtrip:t}}}(c))}return e(n)}}};t.PingIndicator=function(e,t){var n=(0,c.useSelector)(t,u),a=o.Color.lookup(n.networkQuality,[new o.Color(220,40,40),new o.Color(220,200,40),new o.Color(60,220,40)]),d=n.roundtrip?(0,i.toFixed)(n.roundtrip):"--";return(0,r.createVNode)(1,"div","Ping",[(0,r.createComponentVNode)(2,s.Box,{className:"Ping__indicator",backgroundColor:a}),d],0)}},631:function(e,t,n){e.exports=n(632)},632:function(e,t,n){"use strict";n(146),n(158),n(159),n(160),n(161),n(162),n(163),n(164),n(165),n(166),n(167),n(168),n(169),n(170),n(171),n(172),n(174),n(175),n(176),n(177),n(178),n(179),n(181),n(182),n(183),n(185),n(186),n(187),n(113),n(190),n(191),n(193),n(194),n(195),n(196),n(197),n(198),n(199),n(200),n(201),n(202),n(203),n(204),n(206),n(207),n(208),n(209),n(210),n(211),n(212),n(213),n(214),n(216),n(217),n(218),n(219),n(221),n(223),n(224),n(225),n(226),n(227),n(228),n(229),n(230),n(231),n(232),n(233),n(234),n(235),n(236),n(237),n(238),n(239),n(240),n(241),n(242),n(243),n(245),n(246),n(247),n(248),n(249),n(250),n(252),n(253),n(254),n(255),n(256),n(257),n(258),n(259),n(261),n(262),n(263),n(264),n(265),n(266),n(267),n(269),n(270),n(271),n(272),n(273),n(274),n(275),n(276),n(277),n(278),n(279),n(280),n(281),n(287),n(288),n(289),n(290),n(291),n(292),n(293),n(294),n(295),n(296),n(297),n(298),n(299),n(300),n(301),n(123),n(302),n(303),n(304),n(305),n(306),n(307),n(308),n(309),n(310),n(311),n(313),n(314),n(315),n(316),n(317),n(318),n(319),n(320),n(321),n(322),n(323),n(324),n(325),n(326),n(327),n(328),n(329),n(330),n(331),n(332),n(333),n(334),n(335),n(336),n(339),n(340),n(341),n(342),n(343),n(344),n(345),n(346),n(347),n(348),n(349),n(350),n(351),n(352),n(353),n(354),n(355),n(356),n(357),n(358),n(359),n(360),n(361),n(362),n(363),n(364),n(365),n(366),n(367),n(368),n(369),n(370),n(371),n(372),n(374),n(375),n(376),n(377);var r=n(0);n(378),n(379),n(380),n(381),n(382),n(383),n(633),n(634);var o,i,a=n(95),s=n(75),c=(n(94),n(131)),u=n(42),d=n(404),l=n(406),p=n(408),g=n(141),h=n(651),f=n(652);a.perf.mark("inception",null==(o=window.performance)||null==(i=o.timing)?void 0:i.navigationStart),a.perf.mark("init");var m=(0,u.configureStore)({reducer:(0,s.combineReducers)({audio:d.audioReducer,chat:l.chatReducer,ping:p.pingReducer,settings:g.settingsReducer}),middleware:{pre:[l.chatMiddleware,p.pingMiddleware,h.telemetryMiddleware,g.settingsMiddleware,d.audioMiddleware]}}),v=(0,c.createRenderer)((function(){var e=n(653).Panel;return(0,r.createComponentVNode)(2,u.StoreProvider,{store:m,children:(0,r.createComponentVNode)(2,e)})}));!function y(){if("loading"!==document.readyState){for(m.subscribe(v),(0,f.setupExternalLinkCapturing)(),window.update=function(e){return m.dispatch(Byond.parseJson(e))};;){var e=window.__updateQueue__.shift();if(!e)break;window.update(e)}Byond.winset("output",{"is-visible":!1}),Byond.winset("browseroutput",{"is-visible":!0,"is-disabled":!1,pos:"0x0",size:"0x0"})}else document.addEventListener("DOMContentLoaded",y)}()},633:function(e,t,n){},634:function(e,t,n){},635:function(e,t,n){"use strict";t.__esModule=!0,t.useAudio=void 0;var r=n(42),o=n(405);t.useAudio=function(e){return(0,r.useSelector)(e,o.selectAudio)}},636:function(e,t,n){"use strict";t.__esModule=!0,t.audioMiddleware=void 0;var r=n(637);t.audioMiddleware=function(e){var t=!1,n=new r.AudioPlayer;return function(r){return function(o){var i=o.type,a=o.payload;if(t||(t=!0,n.onPlay((function(){e.dispatch({type:"audio/playing"})})),n.onStop((function(){e.dispatch({type:"audio/stopped"})}))),"audio/playMusic"===i){var s=a.url,c=function(e,t){if(null==e)return{};var n,r,o={},i=Object.keys(e);for(r=0;r<i.length;r++)n=i[r],t.indexOf(n)>=0||(o[n]=e[n]);return o}(a,["url"]);return n.play(s,c),r(o)}if("audio/stopMusic"===i)return n.stop(),r(o);if("settings/update"===i||"settings/load"===i){var u=a.adminMusicVolume;return"number"==typeof u&&n.setVolume(u),r(o)}return r(o)}}}},637:function(e,t,n){"use strict";function r(e,t){var n;if("undefined"==typeof Symbol||null==e[Symbol.iterator]){if(Array.isArray(e)||(n=function(e,t){if(!e)return;if("string"==typeof e)return o(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);"Object"===n&&e.constructor&&(n=e.constructor.name);if("Map"===n||"Set"===n)return Array.from(e);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return o(e,t)}(e))||t&&e&&"number"==typeof e.length){n&&(e=n);var r=0;return function(){return r>=e.length?{done:!0}:{done:!1,value:e[r++]}}}throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}return(n=e[Symbol.iterator]()).next.bind(n)}function o(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}t.__esModule=!0,t.AudioPlayer=void 0;var i=(0,n(23).createLogger)("AudioPlayer"),a=function(){function e(){var e=this;Byond.IS_LTE_IE9||(this.node=document.createElement("audio"),this.node.style.setProperty("display","none"),document.body.appendChild(this.node),this.playing=!1,this.volume=1,this.options={},this.onPlaySubscribers=[],this.onStopSubscribers=[],this.node.addEventListener("canplaythrough",(function(){i.log("canplaythrough"),e.playing=!0,e.node.playbackRate=e.options.pitch||1,e.node.currentTime=e.options.start||0,e.node.volume=e.volume,e.node.play();for(var t,n=r(e.onPlaySubscribers);!(t=n()).done;){(0,t.value)()}})),this.node.addEventListener("ended",(function(){i.log("ended"),e.stop()})),this.node.addEventListener("error",(function(t){e.playing&&(i.log("playback error",t.error),e.stop())})),this.playbackInterval=setInterval((function(){e.playing&&(e.options.end>0&&e.node.currentTime>=e.options.end&&e.stop())}),1e3))}var t=e.prototype;return t.destroy=function(){this.node&&(this.node.stop(),document.removeChild(this.node),clearInterval(this.playbackInterval))},t.play=function(e,t){void 0===t&&(t={}),this.node&&(i.log("playing",e,t),this.options=t,this.node.src=e)},t.stop=function(){if(this.node){if(this.playing)for(var e,t=r(this.onStopSubscribers);!(e=t()).done;)(0,e.value)();i.log("stopping"),this.playing=!1,this.node.src=""}},t.setVolume=function(e){this.node&&(this.volume=e,this.node.volume=e)},t.onPlay=function(e){this.onPlaySubscribers.push(e)},t.onStop=function(e){this.onStopSubscribers.push(e)},e}();t.AudioPlayer=a},638:function(e,t,n){"use strict";t.__esModule=!0,t.NowPlayingWidget=void 0;var r=n(0),o=n(14),i=n(2),a=n(42),s=n(141),c=n(405);t.NowPlayingWidget=function(e,t){var n,u=(0,a.useSelector)(t,c.selectAudio),d=(0,a.useDispatch)(t),l=(0,s.useSettings)(t),p=null==(n=u.meta)?void 0:n.title;return(0,r.createComponentVNode)(2,i.Flex,{mx:-.5,align:"center",children:[u.playing&&(0,r.createFragment)([(0,r.createComponentVNode)(2,i.Flex.Item,{shrink:0,mx:.5,color:"label",children:"Now playing:"}),(0,r.createComponentVNode)(2,i.Flex.Item,{mx:.5,grow:1,style:{"white-space":"nowrap",overflow:"hidden","text-overflow":"ellipsis"},children:p||"Unknown Track"})],4)||(0,r.createComponentVNode)(2,i.Flex.Item,{grow:1,color:"label",children:"Nothing to play."}),u.playing&&(0,r.createComponentVNode)(2,i.Flex.Item,{mx:.5,fontSize:"0.9em",children:(0,r.createComponentVNode)(2,i.Button,{tooltip:"Stop",icon:"stop",onClick:function(){return d({type:"audio/stopMusic"})}})}),(0,r.createComponentVNode)(2,i.Flex.Item,{mx:.5,fontSize:"0.9em",children:(0,r.createComponentVNode)(2,i.Knob,{minValue:0,maxValue:1,value:l.adminMusicVolume,step:.0025,stepPixelSize:1,format:function(e){return(0,o.toFixed)(100*e)+"%"},onDrag:function(e,t){return l.update({adminMusicVolume:t})}})})]})}},639:function(e,t,n){"use strict";t.__esModule=!0,t.useSettings=void 0;var r=n(42),o=n(142),i=n(143);t.useSettings=function(e){var t=(0,r.useSelector)(e,i.selectSettings),n=(0,r.useDispatch)(e);return Object.assign({},t,{update:function(e){return n((0,o.updateSettings)(e))}})}},640:function(e,t,n){"use strict";t.__esModule=!0,t.settingsMiddleware=t.sendChangeTheme=void 0;var r=n(96),o=n(1),i=n(142),a=n(143),s=function(e){return(0,o.sendMessage)({type:"changeTheme",payload:{name:e}})};t.sendChangeTheme=s;t.settingsMiddleware=function(e){var t=!1;return function(n){return function(o){var c=o.type,u=o.payload;if(!t)return t=!0,r.storage.get("panel-settings").then((function(t){if(t)if(t.version){var n=t.theme;n&&s(n),e.dispatch((0,i.loadSettings)(t))}else r.storage.clear()})),n(o);if("settings/update"===c){var d=u.theme;return d&&s(d),n(o),void r.storage.set("panel-settings",(0,a.selectSettings)(e.getState()))}return n(o)}}}},641:function(e,t,n){"use strict";t.__esModule=!0,t.settingsReducer=void 0;var r={version:n(642).SETTINGS_VERSION,fontSize:13,lineHeight:1.2,theme:"light",adminMusicVolume:.5};t.settingsReducer=function(e,t){void 0===e&&(e=r);var n=t.type,o=t.payload;if("settings/update"===n)return Object.assign({},e,o);if("settings/load"===n){var i=o;return Object.assign({},e,{fontSize:i.fontSize,lineHeight:i.lineHeight,theme:i.theme,adminMusicVolume:i.adminMusicVolume})}return e}},642:function(e,t,n){"use strict";t.__esModule=!0,t.SETTINGS_VERSION=void 0;t.SETTINGS_VERSION=1},643:function(e,t,n){"use strict";t.__esModule=!0,t.SettingsPanel=void 0;var r=n(0),o=n(14),i=n(2),a=n(42),s=n(142),c=n(143),u=["light","dark"];t.SettingsPanel=function(e,t){var n=(0,a.useSelector)(t,c.selectSettings),d=n.theme,l=n.fontSize,p=n.lineHeight,g=(0,a.useDispatch)(t);return(0,r.createComponentVNode)(2,i.Section,{children:(0,r.createComponentVNode)(2,i.LabeledList,{children:[(0,r.createComponentVNode)(2,i.LabeledList.Item,{label:"Theme",children:(0,r.createComponentVNode)(2,i.Dropdown,{selected:d,options:u,onSelected:function(e){return g((0,s.updateSettings)({theme:e}))}})}),(0,r.createComponentVNode)(2,i.LabeledList.Item,{label:"Font size",children:(0,r.createComponentVNode)(2,i.NumberInput,{width:"4em",step:1,stepPixelSize:10,minValue:12,maxValue:48,value:l,unit:"px",format:function(e){return(0,o.toFixed)(e)},onChange:function(e,t){return g((0,s.updateSettings)({fontSize:t}))}})}),(0,r.createComponentVNode)(2,i.LabeledList.Item,{label:"Line height",children:(0,r.createComponentVNode)(2,i.NumberInput,{width:"4em",step:.01,stepPixelSize:2,minValue:.8,maxValue:5,value:p,format:function(e){return(0,o.toFixed)(e,2)},onDrag:function(e,t){return g((0,s.updateSettings)({lineHeight:t}))}})})]})})}},644:function(e,t,n){"use strict";t.__esModule=!0,t.audioReducer=void 0;var r={playing:!1,track:null};t.audioReducer=function(e,t){void 0===e&&(e=r);var n=t.type,o=t.payload;return"audio/playing"===n?Object.assign({},e,{playing:!0}):"audio/stopped"===n?Object.assign({},e,{playing:!1}):"audio/playMusic"===n?Object.assign({},e,{meta:o}):"audio/stopMusic"===n?Object.assign({},e,{playing:!1,meta:null}):e}},645:function(e,t,n){"use strict";t.__esModule=!0,t.ChatPanel=void 0;var r=n(0),o=n(6),i=n(2),a=n(407);var s=function(e){var t,n;function s(){var t;return(t=e.call(this)||this).ref=(0,r.createRef)(),t.state={scrollTracking:!0},t.handleScrollTrackingChange=function(e){return t.setState({scrollTracking:e})},t}n=e,(t=s).prototype=Object.create(n.prototype),t.prototype.constructor=t,t.__proto__=n;var c=s.prototype;return c.componentDidMount=function(){a.chatRenderer.mount(this.ref.current),a.chatRenderer.events.on("scrollTrackingChanged",this.handleScrollTrackingChange),this.componentDidUpdate()},c.componentWillUnmount=function(){a.chatRenderer.events.off("scrollTrackingChanged",this.handleScrollTrackingChange)},c.componentDidUpdate=function(e){requestAnimationFrame((function(){a.chatRenderer.ensureScrollTracking()})),(!e||(0,o.shallowDiffers)(this.props,e))&&a.chatRenderer.assignStyle({width:"100%",whiteSpace:"pre-wrap",fontSize:this.props.fontSize,lineHeight:this.props.lineHeight})},c.render=function(){var e=this.state.scrollTracking;return(0,r.createFragment)([(0,r.createVNode)(1,"div","Chat",null,1,null,null,this.ref),!e&&(0,r.createComponentVNode)(2,i.Button,{className:"Chat__scrollButton",icon:"arrow-down",onClick:function(){return a.chatRenderer.scrollToBottom()},children:"Scroll to bottom"})],0)},s}(r.Component);t.ChatPanel=s},646:function(e,t,n){"use strict";t.__esModule=!0,t.createUuid=void 0;t.createUuid=function(){var e=(new Date).getTime();return"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g,(function(t){var n=(e+16*Math.random())%16|0;return e=Math.floor(e/16),("x"===t?n:3&n|8).toString(16)}))}},647:function(e,t,n){"use strict";t.__esModule=!0,t.ChatTabs=void 0;var r=n(0),o=n(2),i=n(42),a=n(145),s=n(99);t.ChatTabs=function(e,t){var n=(0,i.useSelector)(t,s.selectChatPages),c=(0,i.useSelector)(t,s.selectCurrentChatPage),u=(0,i.useDispatch)(t);return(0,r.createComponentVNode)(2,o.Tabs,{textAlign:"center",children:n.map((function(e){return(0,r.createComponentVNode)(2,o.Tabs.Tab,{selected:e===c,rightSlot:(0,r.createComponentVNode)(2,o.Box,{fontSize:"0.9em",children:e.count}),onClick:function(){return u((0,a.changeChatPage)(e))},children:e.name},e.id)}))})}},648:function(e,t,n){"use strict";t.__esModule=!0,t.chatMiddleware=void 0;var r=n(96),o=n(23),i=n(145),a=n(144),s=n(407),c=n(99);function u(e,t,n,r,o,i,a){try{var s=e[i](a),c=s.value}catch(u){return void n(u)}s.done?t(c):Promise.resolve(c).then(r,o)}function d(e){return function(){var t=this,n=arguments;return new Promise((function(r,o){var i=e.apply(t,n);function a(e){u(i,r,o,a,s,"next",e)}function s(e){u(i,r,o,a,s,"throw",e)}a(undefined)}))}}(0,o.createLogger)("chat/middleware");var l=function(){var e=d(regeneratorRuntime.mark((function t(e){var n,o,i;return regeneratorRuntime.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:n=(0,c.selectChat)(e.getState()),o=Math.max(0,s.chatRenderer.messages.length-a.MAX_PERSISTED_MESSAGES),i=s.chatRenderer.messages.slice(o).filter((function(e){return"internal"!==e.type})).map((function(e){return(0,s.serializeMessage)(e)})),r.storage.set("chat-state",n),r.storage.set("chat-messages",i);case 5:case"end":return t.stop()}}),t)})));return function(t){return e.apply(this,arguments)}}(),p=function(){var e=d(regeneratorRuntime.mark((function t(e){return regeneratorRuntime.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:r.storage.get("chat-state").then((function(t){t&&e.dispatch((0,i.loadChat)(t))})),r.storage.get("chat-messages").then((function(e){e&&s.chatRenderer.processBatch([].concat(e,[(0,s.createReconnectedMessage)()]))}));case 2:case"end":return t.stop()}}),t)})));return function(t){return e.apply(this,arguments)}}();t.chatMiddleware=function(e){var t=!1;return s.chatRenderer.events.on("batchProcessed",(function(t){e.dispatch((0,i.updateMessageCount)(t))})),setInterval((function(){return l(e)}),a.MESSAGE_SAVE_INTERVAL),function(n){return function(r){var o=r.type,a=r.payload;if(!t)return t=!0,p(e),n(r);if("chat/message"!==o){if(o===i.changeChatPage.type){var c=a;return s.chatRenderer.changePage(c),n(r)}return"roundrestart"===o?(l(e),n(r)):n(r)}var u=Array.isArray(a)?a:[a];s.chatRenderer.processBatch(u)}}}},649:function(e,t,n){"use strict";t.__esModule=!0,t.chatReducer=t.initialState=void 0;var r,o=n(13),i=n(145),a=n(144),s=n(99);function c(e,t){var n;if("undefined"==typeof Symbol||null==e[Symbol.iterator]){if(Array.isArray(e)||(n=function(e,t){if(!e)return;if("string"==typeof e)return u(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);"Object"===n&&e.constructor&&(n=e.constructor.name);if("Map"===n||"Set"===n)return Array.from(e);if("Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n))return u(e,t)}(e))||t&&e&&"number"==typeof e.length){n&&(e=n);var r=0;return function(){return r>=e.length?{done:!0}:{done:!1,value:e[r++]}}}throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}return(n=e[Symbol.iterator]()).next.bind(n)}function u(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}var d={currentPage:a.DEFAULT_PAGE.id,pageById:(r={},r[a.DEFAULT_PAGE.id]=a.DEFAULT_PAGE,r)};t.initialState=d;t.chatReducer=function(e,t){void 0===e&&(e=d);var n=t.type,r=t.payload;if(n===i.changeChatPage.type){var a=r;return Object.assign({},e,{currentPage:a.id})}if(n===i.updateMessageCount.type){for(var u,l=r,p=(0,o.toArray)(e.pageById),g=Object.assign({},e.pageById),h=c(p);!(u=h()).done;){for(var f=u.value,m=f.count||0,v=0,y=Object.keys(l);v<y.length;v++){var S=y[v];(0,s.canPageAcceptType)(f,S)&&(m+=l[S])}f.count!==m&&(g[f.id]=Object.assign({},f,{count:m}))}return Object.assign({},e,{pageById:g})}return e}},650:function(e,t,n){"use strict";t.__esModule=!0,t.Color=void 0;var r=function(){function e(e,t,n,r){void 0===e&&(e=0),void 0===t&&(t=0),void 0===n&&(n=0),void 0===r&&(r=1),Object.assign(this,{r:e,g:t,b:n,a:r})}return e.prototype.toString=function(){return"rgba("+(0|this.r)+", "+(0|this.g)+", "+(0|this.b)+", "+(0|this.a)+")"},e}();t.Color=r,r.fromHex=function(e){return new r(parseInt(e.substr(1,2),16),parseInt(e.substr(3,2),16),parseInt(e.substr(5,2),16))},r.lerp=function(e,t,n){return new r((t.r-e.r)*n+e.r,(t.g-e.g)*n+e.g,(t.b-e.b)*n+e.b,(t.a-e.a)*n+e.a)},r.lookup=function(e,t){void 0===t&&(t=[]);var n=t.length;if(n<2)throw new Error("Needs at least two colors!");var o=e*(n-1);if(e<1e-4)return t[0];if(e>=.9999)return t[n-1];var i=o%1,a=0|o;return r.lerp(t[a],t[a+1],i)}},651:function(e,t,n){"use strict";t.__esModule=!0,t.telemetryMiddleware=void 0;var r=n(1),o=n(96);function i(e,t,n,r,o,i,a){try{var s=e[i](a),c=s.value}catch(u){return void n(u)}s.done?t(c):Promise.resolve(c).then(r,o)}var a=(0,n(23).createLogger)("telemetry");t.telemetryMiddleware=function(e){var t,n;return function(s){return function(c){var u,d=c.type,l=c.payload;if("telemetry/request"!==d)return"backend/update"===d?(s(c),void(u=regeneratorRuntime.mark((function h(){var r,i,s,c;return regeneratorRuntime.wrap((function(u){for(;;)switch(u.prev=u.next){case 0:if(i=null==l||null==(r=l.config)?void 0:r.client){u.next=4;break}return a.error("backend/update payload is missing client data!"),u.abrupt("return");case 4:if(t){u.next=13;break}return u.next=7,o.storage.get("telemetry");case 7:if(u.t0=u.sent,u.t0){u.next=10;break}u.t0={};case 10:(t=u.t0).connections||(t.connections=[]),a.debug("retrieved telemetry from storage",t);case 13:s=!1,t.connections.find((function(e){return n=i,(t=e).ckey===n.ckey&&t.address===n.address&&t.computer_id===n.computer_id;var t,n}))||(s=!0,t.connections.unshift(i),t.connections.length>10&&t.connections.pop()),s&&(a.debug("saving telemetry to storage",t),o.storage.set("telemetry",t)),n&&(c=n,n=null,e.dispatch({type:"telemetry/request",payload:c}));case 18:case"end":return u.stop()}}),h)})),function(){var e=this,t=arguments;return new Promise((function(n,r){var o=u.apply(e,t);function a(e){i(o,n,r,a,s,"next",e)}function s(e){i(o,n,r,a,s,"throw",e)}a(undefined)}))})()):s(c);if(!t)return a.debug("deferred"),void(n=l);a.debug("sending");var p=(null==l?void 0:l.limits)||{},g=t.connections.slice(0,p.connections);(0,r.sendMessage)({type:"telemetry",payload:{connections:g}})}}}},652:function(e,t,n){"use strict";t.__esModule=!0,t.setupExternalLinkCapturing=void 0;var r=n(1);t.setupExternalLinkCapturing=function(){document.addEventListener("click",(function(e){var t=String(e.target.tagName).toLowerCase(),n=String(e.target.href);"a"===t&&("?"===n.charAt(0)||n.startsWith(location.origin)||n.startsWith("byond://")||(e.preventDefault(),(0,r.sendMessage)({type:"openLink",payload:{url:n}})))}))}},653:function(e,t,n){"use strict";t.__esModule=!0,t.Panel=void 0;var r=n(0),o=n(2),i=n(3),a=n(404),s=n(406),c=n(408),u=n(141),d=n(1);n(42);t.Panel=function(e,t){var n=(0,a.useAudio)(t),l=(0,u.useSettings)(t),p=(0,d.useLocalState)(t,"audioOpen",n.playing),g=p[0],h=p[1],f=(0,d.useLocalState)(t,"settingsOpen",!1),m=f[0],v=f[1];return(0,r.createComponentVNode)(2,i.Pane,{theme:l.theme,fontSize:l.fontSize+"px",children:(0,r.createComponentVNode)(2,o.Flex,{direction:"column",height:"100%",children:[(0,r.createComponentVNode)(2,o.Flex.Item,{children:(0,r.createComponentVNode)(2,o.Section,{fitted:!0,children:(0,r.createComponentVNode)(2,o.Flex,{mx:.5,align:"center",children:[(0,r.createComponentVNode)(2,o.Flex.Item,{mx:.5,grow:1,children:(0,r.createComponentVNode)(2,s.ChatTabs)}),(0,r.createComponentVNode)(2,o.Flex.Item,{mx:.5,children:(0,r.createComponentVNode)(2,c.PingIndicator)}),(0,r.createComponentVNode)(2,o.Flex.Item,{mx:.5,children:(0,r.createComponentVNode)(2,o.Button,{color:"grey",selected:g||n.playing,icon:"music",onClick:function(){return h(!g)}})}),(0,r.createComponentVNode)(2,o.Flex.Item,{mx:.5,children:(0,r.createComponentVNode)(2,o.Button,{icon:"cog",selected:m,onClick:function(){return v(!m)}})})]})})}),g&&(0,r.createComponentVNode)(2,o.Flex.Item,{mt:1,children:(0,r.createComponentVNode)(2,o.Section,{children:(0,r.createComponentVNode)(2,a.NowPlayingWidget)})}),m&&(0,r.createComponentVNode)(2,o.Flex.Item,{mt:1,children:(0,r.createComponentVNode)(2,u.SettingsPanel)}),(0,r.createComponentVNode)(2,o.Flex.Item,{mt:1,grow:1,children:(0,r.createComponentVNode)(2,o.Section,{fill:!0,fitted:!0,position:"relative",children:(0,r.createComponentVNode)(2,i.Pane.Content,{scrollable:!0,children:(0,r.createComponentVNode)(2,s.ChatPanel,{lineHeight:l.lineHeight})})})})]})})}},99:function(e,t,n){"use strict";t.__esModule=!0,t.canPageAcceptType=t.selectChatPageById=t.selectCurrentChatPage=t.selectChatPages=t.selectChat=void 0;var r=n(13);t.selectChat=function(e){return e.chat};t.selectChatPages=function(e){return(0,r.toArray)(e.chat.pageById)};t.selectCurrentChatPage=function(e){return e.chat.pageById[e.chat.currentPage]};t.selectChatPageById=function(e){return function(t){return t.chat.pageById[e]}};t.canPageAcceptType=function(e,t){return e.acceptedTypes[t]}}});