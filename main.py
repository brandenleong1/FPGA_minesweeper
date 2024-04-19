
import pygame 
from pygame.locals import *
import random
from math import floor

# -------------------- TOP SECTION ------------------------
BG_COLOR = (50, 50, 50)
TILE_COLOR = (100, 100, 100)
FLAG_COLOR = (255, 100, 100)
TEXT_COLOR = (253,253,253)
TEXT_BOX_COLOR = (169, 169, 169)
WIDTH = 800
HEIGHT = 400
GRID_NUM = (40, 20) # row and columns
GAME_NAME = "MineSweeper"
STATES = ["INIT", "START", "GEN_MAP", "IDLE", "TOGGLE_FLAG", "OPEN_GRID", "GAMEOVER"]

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
            row.append(random.randint(0,5))
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
                    row.append(-100) # For debugging purposes
            else:
                row.append(-1) # If it's a mine
        grid.append(row)
                

def drawCell(x:int, y:int):
    global grid, tileSz, screen

    rect = pygame.Rect(x*tileSz, y*tileSz, tileSz, tileSz)
    if grid[x][y] > 9 and grid[x][y] < 20: # If it's open
        pygame.draw.rect(screen, TILE_COLOR if grid[x][y] != -1 else (100,1,1), rect)
        pygame.display.update()
        font = pygame.font.Font('freesansbold.ttf', 15)
        text = font.render(str(grid[x][y]%10), True, TEXT_COLOR, TILE_COLOR)
        textRect = text.get_rect()
        textRect.center = ((x*tileSz)+tileSz / 2,  (y*tileSz)+tileSz / 2)
        screen.blit(text, textRect)
    elif grid[x][y] >= 20: # If there's a flag
        pygame.draw.rect(screen, FLAG_COLOR, rect)
        pygame.display.update()

    else: # If it's still a untouched cell
        pygame.draw.rect(screen, TILE_COLOR, rect)
        pygame.display.update()

def drawGrid():
    for x in range(0, GRID_NUM[0]):
        for y in range(0, GRID_NUM[1]):
            drawCell(x, y)

def getUserInput():
    global running, pos, state, started
    pressed = pygame.key.get_pressed()
    for event in pygame.event.get(): 
        # Check for QUIT event	 
        if started == 1:
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
            elif pressed[K_f]:
                state = "TOGGLE_FLAG"
        else:
            if pressed[K_f]:
                state = STATES[2]
        
    
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
    pos = [int(GRID_NUM[0]/2-1),int(GRID_NUM[1]/2-1)]
    grid = []
    tileSz = 20
    started = 0


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
            # Update the display using flip 
            pygame.display.flip()
            state = STATES[1]
            print("Inited pygame")
        
        elif (state == STATES[1]):
            largeFont = pygame.font.SysFont('Grand9K Pixel',50)
            mainFont = pygame.font.SysFont('Grand9K Pixel',35)

            mainscreenText = largeFont.render("Minesweeper", True, TEXT_COLOR, TILE_COLOR)
            mainscreenRect = mainscreenText.get_rect()
            mainscreenRect.center = ((800/2, 400/2))
            screen.blit(mainscreenText , mainscreenRect)
            pygame.display.update()
            print("Main screen")
            state = "IDLE"
        
        elif (state == STATES[2]):
            generateMap()
            drawGrid()
            pygame.display.flip()
            started = 1
            state = STATES[3]

        elif state == "TOGGLE_FLAG":
            if (grid[pos[0]][pos[1]] >= 19):
                grid[pos[0]][pos[1]] -= 20
            elif (grid[pos[0]][pos[1]] < 9):
                grid[pos[0]][pos[1]] += 20
            drawCell(pos[0], pos[1])
            pygame.display.update()
            state = "IDLE"
        
        elif state=="OPEN_GRID":
            cells2show = random.randrange(1, 10)
            cellsShown = 0
            rect = pygame.Rect(pos[0]*tileSz, pos[1]*tileSz, tileSz, tileSz)
            # print(grid)
            if (grid[pos[0]][pos[1]] == -1):
                # Game over
                pygame.draw.rect(screen, (255,1,1), rect)
                state = "GAMEOVER"
            elif (grid[pos[0]][pos[1]] < 9): # Not flagged and already opened
                pq = [(pos[0], pos[1])]
                while pq != []:
                    # Open valid cell
                    try:
                        # print(f"Opening pos is {pq[0][0]} by {pq[0][1]}")
                        if grid[pq[0][0]][pq[0][1]] < 9 and grid[pq[0][0]][pq[0][1]] != -1:
                            grid[pq[0][0]][pq[0][1]] += 10
                    except Exception as e:
                        print(f"Got exception {e}")
                        print(f"pos is {pq[0][0]} by {pq[0][1]}")

                    # Add surrounding cells to grid:
                    for i in range(-1, 2):
                        for j in range (-1, 2):
                            try:
                                if cellsShown == cells2show:
                                    break
                                if (min(pq[0][0]+i, pq[0][1]+j) >= 0 and pq[0][0]+i < GRID_NUM[0] and pq[0][1]+j < GRID_NUM[1] and \
                                    grid[pq[0][0]+i][pq[0][1]+j] < 9 and grid[pq[0][0]+i][pq[0][1]+j] != -1 ):
                                    cellsShown += 1
                                    pq.append((pq[0][0]+i, pq[0][1]+j))
                                    grid[pq[0][0]+i][pq[0][1]+j] += 10
                                    drawCell(pq[0][0]+i, pq[0][1]+j)
                            except Exception as e:
                                print(f"Got exception {e}")
                                print(f"pos is {pq[0][0]+i} by {pq[0][1]+j}")
                        else:
                            break
                    pq.pop(0)
                state = "IDLE"
            else:
                print("error!")
                state = "IDLE"

            # screen.fill(BG_COLOR) 
            pygame.display.update()

        elif (state == "IDLE"):
            print("Idling")
            getUserInput()
        
        elif (state == "GAMEOVER"):
            largeFont = pygame.font.SysFont('Grand9K Pixel',50)
            mainFont = pygame.font.SysFont('Grand9K Pixel',35)

            mainscreenText = largeFont.render("GAMEOVER", True, TEXT_COLOR, TILE_COLOR)
            mainscreenRect = mainscreenText.get_rect()
            mainscreenRect.center = ((800/2, 400/2))
            screen.blit(mainscreenText , mainscreenRect)
            pygame.display.update()
            print("Main screen")
            state = "IDLE"
        
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

