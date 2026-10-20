Due to the fact browse_rsc can't create subdirectories, every time you update font-awesome you'll need to change relative webfont references in all.min.css eg ../fonts/fa-regular-400.woff2 => fa-regular-400.woff2 (or whatever you call it in asset datum)

Second change is ~~ripping out file types other than woff and eot(ie8) from the css~~ making all fonts woff2 because we're on a browser system that isn't stone age garbo and make sure relevant licenses are included

Finally, removing brand related css (whatever that means)
