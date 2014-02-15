var gulp = require ('gulp')

var jade = require ('gulp-jade')
var livereload = require ('gulp-livereload')
var browserify = require('gulp-browserify');
var nodemon = require('gulp-nodemon');


var paths={
 templates : 'src/web/**/*.jade',
 scripts : 'src/web/**/*.coffee',
 server : 'src/api/**/*.coffee',
 assets : 'src/web/assets/**/*.*'
};

gulp.task('assets',function(){
 gulp.src(paths.assets).pipe(gulp.dest('src/public/assets')).pipe(livereload())
})

gulp.task('templates',function(){
  gulp.src(paths.templates).pipe(jade()).pipe(gulp.dest('src/public')).pipe(livereload())
});

gulp.task('coffee', function() {
  gulp.src('src/web/app.coffee', { read: false })
      .pipe(browserify({transform: ['coffeeify'],extensions: ['.coffee','.js']}))
      .pipe(gulp.dest('src/public/'))
      .pipe(livereload())
});

gulp.task('server',function(){
  nodemon({script:'src/api/app.coffee',options:'--watch src/api'}).on('restart',livereload())
});

gulp.task('watch',function(){
  gulp.watch (paths.templates,['templates']);
  gulp.watch (paths.scripts,['coffee']);
  gulp.watch (paths.assets,['assets']);
});

gulp.task('default',['templates','coffee','server','watch']);
