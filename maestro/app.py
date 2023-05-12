import flask
from flask_autoindex import AutoIndex

from shelljob import proc
from os.path import exists, basename
from glob import glob

import os

#RMS_data_DIR = '/home/tbyte/RMS_data'
RMS_data_DIR = '/root/RMS_data'

app = flask.Flask(__name__)
files = AutoIndex(app, browse_root=RMS_data_DIR, add_url_rules=False)

@app.route("/files")
@app.route("/files/")
@app.route("/files/<path:path>")
def files_index(path="."):
    return files.render_autoindex(path, endpoint=".files_index")


def get_stations():
    stations = []
    for dir in glob(RMS_data_DIR + "/config/*", recursive = False):
        stations.append(basename(dir))

    return stations

@app.route( '/' )
def root():
    return flask.render_template('index.html', stations=get_stations())

@app.route( '/live' )
def live():
    return flask.render_template('live.html', stations=get_stations())

@app.route( '/stream/log/<id>' )
def stream(id):
    log_file = RMS_data_DIR + "/logs/" + id + ".stdout"
    if exists(log_file) is False:
        flask.abort(404)
        #flask.abort(flask.Response(''))

    g = proc.Group()
    p = g.run( [ "bash", "-c", "tail -n 200 -f " + log_file ] )

    def read_process():
        while g.is_pending():
            lines = g.readlines()
            for proc, line in lines:
                yield line

    return flask.Response( read_process(), mimetype= 'text/plain' )

if __name__ == "__main__":
    app.run(debug=True)