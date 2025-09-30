import discord
from discord.ext import commands, tasks
import sqlite3

intents = discord.Intents.default()
intents.members = True
bot = commands.Bot(command_prefix='!', intents=intents)

# Connect database
conn = sqlite3.connect('rialo.db')
c = conn.cursor()
c.execute('''CREATE TABLE IF NOT EXISTS members (id INTEGER PRIMARY KEY, name TEXT, role TEXT)''')
conn.commit()

# Welcome + auto role
@bot.event
async def on_member_join(member):
    await member.send(f'Welcome {member.name} to Rialo!')
    role = discord.utils.get(member.guild.roles, name="RialONE")
    await member.add_roles(role)
    c.execute('INSERT INTO members (id, name, role) VALUES (?, ?, ?)', (member.id, member.name, "RialONE"))
    conn.commit()

# Example command: Check top content
@bot.command()
async def top_content(ctx):
    # Example: fetch top posts from DB
    await ctx.send("Top content creators this week: @RialORBIT members")

bot.run('YOUR_BOT_TOKEN')

