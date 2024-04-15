
import pygame 
from pygame.locals import *
import random
from math import floor

# -------------------- TOP SECTION ------------------------
BG_COLOR = (50, 50, 50)
TILE_COLOR = (100, 100, 100)
FLAG_COLOR = (255, 100, 100)
TEXT_COLOR = (255,255,255)
WIDTH = 800
HEIGHT = 400
GRID_NUM = (40, 20) # row and columns
GAME_NAME = "MineSweeper"
STATES = ["INIT", "START", "IDLE", "OPEN_GRID"]

def top():

    pass
# ------------------ END TOP SECTION -----------------------

def generateMap():
    global grid
    # We need to implement a random number generator
    # $urandom to generate unsigned random numbers that you expect between 0 to 10 and 0 to 20.

    # Generate the mines
    mineGrid = []
    for cell_x in range(GRID_NUM[0]):
        row = []
        for cell_y in range(GRID_NUM[1]):
            row.append(random.randint(0,10))
            row[cell_y] = 0 if row[cell_y] != 0 else 1 # Normalize. Mine is 1 and no mine is 0
        mineGrid.append(row)
    
    # Generate the correct numbers
    for x in range(len(mineGrid)):
        row = []
        for y in range(len(mineGrid[x])):
            if (mineGrid[x][y]==0):
                if (x == 0 and y==0):
                    row.append(mineGrid[x+1][y] + mineGrid[x+1][y+1] + mineGrid[x][y+1])
                elif (x == GRID_NUM[0]-1 and y == 0):
                    row.append(mineGrid[x-1][y] + mineGrid[x-1][y+1] + mineGrid[x][y+1])
                elif (x == GRID_NUM[0]-1 and y == GRID_NUM[1]-1):
                    row.append(mineGrid[x-1][y] + mineGrid[x-1][y-1] + mineGrid[x][y-1])
                elif (x == 0 and y == GRID_NUM[1]-1):
                    row.append(mineGrid[x+1][y] + mineGrid[x+1][y-1] + mineGrid[x][y-1])
                elif (x == 0 and y != 0 and y != GRID_NUM[1]-1):
                    row.append(mineGrid[x+1][y] + mineGrid[x+1][y-1] + mineGrid[x+1][y+1] + mineGrid[x][y-1] + mineGrid[x][y+1])
                elif (x == GRID_NUM[0]-1 and y != 0 and y != GRID_NUM[1]-1):
                    row.append(mineGrid[x-1][y] + mineGrid[x-1][y-1] + mineGrid[x-1][y+1] + mineGrid[x][y-1] + mineGrid[x][y+1])
                elif (y == 0 and x != 0 and x != GRID_NUM[0]-1):
                    row.append(mineGrid[x-1][y] + mineGrid[x+1][y] + mineGrid[x-1][y+1] + mineGrid[x][y+1] + mineGrid[x+1][y+1])
                elif (y == GRID_NUM[1]-1 and x != 0 and x != GRID_NUM[0]-1):
                    row.append(mineGrid[x-1][y] + mineGrid[x+1][y] + mineGrid[x-1][y-1] + mineGrid[x][y-1] + mineGrid[x+1][y-1])
                elif (y != 0 and y != GRID_NUM[1]-1 and x != 0 and x != GRID_NUM[0]-1):
                    row.append(mineGrid[x-1][y] + mineGrid[x+1][y] + mineGrid[x-1][y-1] + mineGrid[x][y-1] + mineGrid[x+1][y-1] + mineGrid[x-1][y+1] + mineGrid[x][y+1] + mineGrid[x+1][y+1])
                else:
                    row.append(-100)
            else:
                row.append(-1)
        grid.append(row)
                

def drawCell(x:int, y:int):
    global grid, tileSz, screen

    rect = pygame.Rect(x*tileSz, y*tileSz, tileSz, tileSz)
    pygame.draw.rect(screen, TILE_COLOR if grid[x][y] != -1 else (1,1,1), rect)
    pygame.display.update()
    font = pygame.font.Font('freesansbold.ttf', 15)
    text = font.render(str(grid[x][y]), True, TEXT_COLOR, TILE_COLOR)
    textRect = text.get_rect()
    textRect.center = ((x*tileSz)+tileSz / 2,  (y*tileSz)+tileSz / 2)
    screen.blit(text, textRect)

def drawGrid():
    for x in range(0, GRID_NUM[0]):
        for y in range(0, GRID_NUM[1]):
            drawCell(x, y)

def getUserInput():
    global running, pos, open_grid, state
    pressed = pygame.key.get_pressed()
    for event in pygame.event.get(): 
        # Check for QUIT event	 
        if event.type == pygame.QUIT: 
            running = False
        if pressed[K_UP]:
            state = "MOVE_UP"
        elif pressed[K_DOWN]:
            state = "MOVE_DOWN"
        elif pressed[K_LEFT]:
            state = "MOVE_LEFT"
        elif pressed[K_RIGHT]:
            state = "MOVE_RIGHT"
        elif pressed[K_SPACE]:
            state = "OPEN_GRID"
        
    
def moveCursor(x=0, y=0):
    # put a purple cell where your cursor is and regenerate the previous cell the cursor was on
     
    global pos
    x *= -1 # Correcting
    pos[0] -= x
    pos[1] -= y

    # Make the cell it is going to purple
    new_rect = pygame.Rect(pos[0]*tileSz, pos[1]*tileSz, tileSz, tileSz)
    pygame.draw.rect(screen, (145,13,100), new_rect)

    # print(grid[pos[0]][pos[1]])
    # print(pos[0],pos[1])
    # print(grid[pos[0]+x][pos[1]+y])

    # Regenerates the previous cell
    drawCell(pos[0]+x, pos[1]+y)

if __name__ == "__main__":
    global screen, clock, running, grid, tileSz
    
    # Init variables
    #-----------------------------------------------------
    state = STATES[0]
    running = True
    open_grid = False
    pos = [int(GRID_NUM[0]/2-1),int(GRID_NUM[1]/2-1)]
    grid = []
    tileSz = 20


    # Main Program variables
    #-----------------------------------------------------
    while running:
        if (state == STATES[0]):
            pygame.init()
            screen = pygame.display.set_mode((WIDTH, HEIGHT)) 
            clock = pygame.time.Clock()
            # Set the caption of the screen 
            pygame.display.set_caption(GAME_NAME)
            # Fill the background colour to the screen 
            screen.fill(BG_COLOR) 
            generateMap()
            drawGrid()
            
            # Update the display using flip 
            pygame.display.update()
            state = "IDLE"

        elif state == "RUNNING_FLAG_CELL":
            grid[pos[0]][pos[1]] = -2
        
        elif state=="OPEN_GRID":
            grid[pos[0]][pos[1]] = -1
            rect = pygame.Rect(pos[0]*tileSz, pos[1]*tileSz, tileSz, tileSz)
            # print(grid)
            if (grid[pos[0]][pos[1]]):
                pygame.draw.rect(screen, (1,1,1), rect)
            else:
                pygame.draw.rect(screen, (255,255,255), rect)
            # screen.fill(BG_COLOR) 
            pygame.display.update()
            state = "IDLE"
            open_grid = False

        elif (state == "IDLE"):
            getUserInput()
        
        elif (state == "MOVE_UP"):
            moveCursor(0, 1)
            pygame.display.update()
            state = "IDLE"

        elif (state == "MOVE_DOWN"):
            moveCursor(0, -1)
            pygame.display.update()
            state = "IDLE"

        elif (state == "MOVE_LEFT"):
            moveCursor(-1, 0)
            pygame.display.update()
            state = "IDLE"

        elif (state == "MOVE_RIGHT"):
            moveCursor(1, 0)
            pygame.display.update()
            state = "IDLE"


            

    print("Minesweeper finished!")

