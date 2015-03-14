modules = {
    calendar {
        dependsOn 'jquery'
        resource url:'/js/moment.min.js'
        resource url:'/js/fullcalendar.min.js'
        resource url:'/js/lang-all.js'
        resource url:'/css/fullcalendar.css'
        resource url:'/css/fullcalendar.print.css', attrs:[media:'print']
    }
    qtip {
        dependsOn 'jquery'
        resource url:'/js/jquery.qtip.min.js'
        resource url:'/css/jquery.qtip.min.css'
    }
}