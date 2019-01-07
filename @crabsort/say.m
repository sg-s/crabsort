function say(self,msg)

self.handles.main_fig.Name = [self.file_name ' -- ' msg];
self.handles.main_fig.UserData = now;
drawnow limitrate